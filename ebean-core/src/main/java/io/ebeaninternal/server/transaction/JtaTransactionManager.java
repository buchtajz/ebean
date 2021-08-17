package io.ebeaninternal.server.transaction;

import io.ebean.config.ExternalTransactionManager;
import io.ebean.util.JdbcClose;
import io.ebeaninternal.api.SpiTransaction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.persistence.PersistenceException;
import javax.sql.DataSource;
import javax.transaction.Status;
import javax.transaction.Synchronization;
import javax.transaction.TransactionSynchronizationRegistry;
import javax.transaction.UserTransaction;

/**
 * Hook into external JTA transaction manager.
 */
public final class JtaTransactionManager implements ExternalTransactionManager {

  private static final Logger logger = LoggerFactory.getLogger(JtaTransactionManager.class);

  private static final String EBEAN_TXN_RESOURCE = "EBEAN_TXN_RESOURCE";

  /**
   * The Ebean transaction manager.
   */
  private TransactionManager transactionManager;

  private TransactionScopeManager scope;

  /**
   * Instantiates a new spring aware transaction scope manager.
   */
  public JtaTransactionManager() {
  }

  /**
   * Initialise this with the Ebean internal transaction manager.
   */
  @Override
  public void setTransactionManager(Object txnMgr) {

    // RB: At this stage not exposing TransactionManager to
    // the public API and hence the Object type and casting here

    this.transactionManager = (TransactionManager) txnMgr;
    this.scope = transactionManager.scope();
  }

  /**
   * Return the current dataSource taking into account multi-tenancy.
   */
  private DataSource dataSource() {
    return transactionManager.getDataSource();
  }

  private TransactionSynchronizationRegistry getSyncRegistry() {
    try {
      InitialContext ctx = new InitialContext();
      return (TransactionSynchronizationRegistry) ctx.lookup("java:comp/TransactionSynchronizationRegistry");
    } catch (NamingException e) {
      throw new PersistenceException(e);
    }
  }

  private UserTransaction getUserTransaction() {
    try {
      InitialContext ctx = new InitialContext();
      return (UserTransaction) ctx.lookup("java:comp/UserTransaction");
    } catch (NamingException e) {
      // assuming CMT
      return new DummyUserTransaction();
    }
  }

  /**
   * Looks for a current Spring managed transaction and wraps/returns that as a Ebean transaction.
   * <p>
   * Returns null if there is no current spring transaction (lazy loading outside a spring txn etc).
   * </p>
   */
  @Override
  public Object getCurrentTransaction() {

    TransactionSynchronizationRegistry syncRegistry = getSyncRegistry();

    SpiTransaction t = (SpiTransaction) syncRegistry.getResource(EBEAN_TXN_RESOURCE);
    if (t != null) {
      // we have already seen this transaction
      return t;
    }

    // check current Ebean transaction
    SpiTransaction currentEbeanTransaction = scope.getInScope();
    if (currentEbeanTransaction != null) {
      // NOT expecting this so log WARNING
      String msg = "JTA Transaction - no current txn BUT using current Ebean one " + currentEbeanTransaction.getId();
      logger.warn(msg);
      return currentEbeanTransaction;
    }

    UserTransaction ut = getUserTransaction();
    if (ut == null) {
      // no current JTA transaction
      if (logger.isDebugEnabled()) {
        logger.debug("JTA Transaction - no current txn");
      }
      return null;
    }

    // This is a transaction that Ebean has not seen before.

    // "wrap" it in a Ebean specific JtaTransaction
    String txnId = String.valueOf(System.currentTimeMillis());
    JtaTransaction newTrans = new JtaTransaction(txnId, true, ut, dataSource(), transactionManager);

    // create and register transaction listener
    JtaTxnListener txnListener = createJtaTxnListener(newTrans);

    syncRegistry.putResource(EBEAN_TXN_RESOURCE, newTrans);
    syncRegistry.registerInterposedSynchronization(txnListener);

    // also put in Ebean ThreadLocal
    scope.set(newTrans);
    return newTrans;
  }


  /**
   * Create a listener to register with JTA to enable Ebean to be
   * notified when transactions commit and rollback.
   * <p>
   * This is used by Ebean to notify it's appropriate listeners and maintain it's server
   * cache etc.
   * </p>
   */
  private JtaTxnListener createJtaTxnListener(SpiTransaction t) {
    return new JtaTxnListener(transactionManager, t);
  }

  private static class DummyUserTransaction implements UserTransaction {

    @Override
    public void begin() {
    }

    @Override
    public void commit() throws SecurityException, IllegalStateException {
    }

    @Override
    public int getStatus() {
      return 0;
    }

    @Override
    public void rollback() throws IllegalStateException, SecurityException {
    }

    @Override
    public void setRollbackOnly() throws IllegalStateException {
    }

    @Override
    public void setTransactionTimeout(int seconds) {
    }
  }

  /**
   * A JTA Transaction Synchronization that we register to get notified when a
   * managed transaction has been committed or rolled back.
   * <p>
   * When Ebean is notified (of the commit/rollback) it can then manage its
   * cache, notify BeanPersistListeners etc.
   * </p>
   */
  private static class JtaTxnListener implements Synchronization {

    private final TransactionManager transactionManager;

    private final SpiTransaction transaction;

    private JtaTxnListener(TransactionManager transactionManager, SpiTransaction t) {
      this.transactionManager = transactionManager;
      this.transaction = t;
    }

    @Override
    public void beforeCompletion() {
      transaction.preCommit();
    }

    @Override
    public void afterCompletion(int status) {
      switch (status) {
        case Status.STATUS_COMMITTED:
          if (logger.isDebugEnabled()) {
            logger.debug("Jta Txn [" + transaction.getId() + "] committed");
          }
          transaction.postCommit();
          // Remove this transaction object as it is completed
          transactionManager.scope().clearExternal();
          break;

        case Status.STATUS_ROLLEDBACK:
          if (logger.isDebugEnabled()) {
            logger.debug("Jta Txn [" + transaction.getId() + "] rollback");
          }
          transaction.postRollback(null);
          // Remove this transaction object as it is completed
          transactionManager.scope().clearExternal();
          break;

        default:
          if (logger.isDebugEnabled()) {
            logger.debug("Jta Txn [" + transaction.getId() + "] status:" + status);
          }
      }

      // No matter the completion status of the transaction, we release the connection we got from the pool.
      JdbcClose.close(transaction.getInternalConnection());
    }
  }

}
