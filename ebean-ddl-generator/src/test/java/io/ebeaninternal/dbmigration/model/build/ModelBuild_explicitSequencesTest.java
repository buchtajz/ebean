package io.ebeaninternal.dbmigration.model.build;


import io.ebean.DatabaseFactory;
import io.ebean.config.DatabaseConfig;
import io.ebeaninternal.api.SpiEbeanServer;
import io.ebeaninternal.dbmigration.ddlgeneration.DdlOptions;
import io.ebeaninternal.dbmigration.ddlgeneration.Helper;
import io.ebeaninternal.dbmigration.model.CurrentModel;
import io.localtest.BaseTestCase;
import org.junit.jupiter.api.Test;
import org.tests.model.basic.Person;
import org.tests.model.basic.Phone;

import java.io.IOException;

import static org.assertj.core.api.Assertions.assertThat;

class ModelBuild_explicitSequencesTest extends BaseTestCase {

  private SpiEbeanServer createServer(boolean postgres) {

    DatabaseConfig config = new DatabaseConfig();
    config.setName("h2");
    config.loadFromProperties();
    config.setName("h2other");
    config.setDdlGenerate(false);
    config.setDdlRun(false);
    config.setDdlExtra(false);
    config.setDefaultServer(false);
    config.setRegister(false);

    config.setDatabasePlatformName(postgres ? "postgres" : "h2");

    config.addClass(Person.class);
    config.addClass(Phone.class);
    return (SpiEbeanServer) DatabaseFactory.create(config);
  }

  @Test
  void test() throws IOException {
    SpiEbeanServer ebeanServer = createServer(false);
    try {
      CurrentModel currentModel = new CurrentModel(ebeanServer);

      String apply = currentModel.getCreateDdl();
      assertThat(apply)
        .startsWith("-- Generated by ebean")
        .endsWith(Helper.asText(this, "/assert/ModelBuild_explicitSequencesTest/apply.sql"));

    } finally {
      ebeanServer.shutdown();
    }
  }

  @Test
  void test_asPostgres() throws IOException {
    SpiEbeanServer ebeanServer = createServer(true);
    try {
      CurrentModel currentModel = new CurrentModel(ebeanServer);
      final DdlOptions ddlOptions = currentModel.getDdlOptions();
      ddlOptions.setForeignKeySkipCheck(true);

      String apply = currentModel.getCreateDdl();
      assertThat(apply)
        .startsWith("-- Generated by ebean")
        .endsWith(Helper.asText(this, "/assert/ModelBuild_explicitSequencesTest/pg-apply.sql"));
    } finally {
      ebeanServer.shutdown(true, false);
    }
  }

}
