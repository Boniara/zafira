CREATE SCHEMA management;

SET SCHEMA 'management';


CREATE TABLE TENANCIES (
 ID SERIAL,
 NAME VARCHAR(255) NOT NULL,
 MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);
CREATE UNIQUE INDEX tenancy_name_unique ON tenancies (name);


CREATE TABLE WIDGET_TEMPLATES (
 ID SERIAL,
 NAME VARCHAR(255) NOT NULL,
 DESCRIPTION VARCHAR(255) NOT NULL,
 TYPE VARCHAR(20)  NOT NULL,
 SQL TEXT NULL,
 CHART_CONFIG TEXT NULL,
 PARAMS_CONFIG TEXT NULL,
 LEGEND_CONFIG TEXT NULL,
 PARAMS_CONFIG_SAMPLE TEXT NULL,
 HIDDEN BOOLEAN NOT NULL DEFAULT FALSE,
 MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);
CREATE UNIQUE INDEX WIDGET_TEMPLATES_NAME_UNIQUE ON WIDGET_TEMPLATES (NAME);
