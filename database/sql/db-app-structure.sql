CREATE SCHEMA IF NOT EXISTS zafira;

SET SCHEMA 'zafira';

DROP FUNCTION IF EXISTS update_timestamp();
CREATE FUNCTION update_timestamp() RETURNS trigger AS $update_timestamp$
    BEGIN
        NEW.modified_at := current_timestamp;
        RETURN NEW;
    END;
$update_timestamp$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS USERS;
CREATE TABLE USERS (
  ID SERIAL,
  USERNAME VARCHAR(100) NOT NULL,
  PASSWORD VARCHAR(50) NULL DEFAULT '',
  EMAIL VARCHAR(100) NULL,
  FIRST_NAME VARCHAR(100) NULL,
  LAST_NAME VARCHAR(100) NULL,
  LAST_LOGIN TIMESTAMP NULL,
  COVER_PHOTO_URL TEXT NULL,
  SOURCE VARCHAR(20) NOT NULL DEFAULT 'INTERNAL',
  STATUS VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  RESET_TOKEN VARCHAR(255) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX USERNAME_UNIQUE ON USERS (USERNAME);
CREATE UNIQUE INDEX USER_EMAIL_UNIQUE ON USERS (EMAIL) WHERE EMAIL IS NOT NULL;
CREATE TRIGGER update_timestamp_users BEFORE INSERT OR UPDATE ON USERS
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_SUITES;
CREATE TABLE IF NOT EXISTS TEST_SUITES (
  ID SERIAL,
  NAME VARCHAR(200) NOT NULL,
  DESCRIPTION TEXT NULL,
  FILE_NAME VARCHAR(255) NOT NULL DEFAULT '',
  USER_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_SUITES_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX NAME_FILE_USER_UNIQUE ON TEST_SUITES (NAME, FILE_NAME, USER_ID);
CREATE INDEX FK_TEST_SUITE_USER_ASC ON TEST_SUITES (USER_ID);
CREATE TRIGGER update_timestamp_test_suits BEFORE INSERT OR UPDATE ON TEST_SUITES
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();



DROP TABLE IF EXISTS PROJECTS;
CREATE TABLE IF NOT EXISTS PROJECTS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  DESCRIPTION TEXT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX NAME_UNIQUE ON PROJECTS (NAME);
CREATE TRIGGER update_timestamp_projects BEFORE INSERT OR UPDATE ON PROJECTS
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_CASES;
CREATE TABLE IF NOT EXISTS TEST_CASES (
  ID SERIAL,
  TEST_CLASS VARCHAR(255) NOT NULL,
  TEST_METHOD VARCHAR(255) NOT NULL,
  INFO TEXT NULL,
  TEST_SUITE_ID INT NOT NULL,
  PRIMARY_OWNER_ID INT NOT NULL,
  SECONDARY_OWNER_ID INT NULL,
  PROJECT_ID INT NULL,
  STATUS VARCHAR(20) NOT NULL DEFAULT 'UNKNOWN',
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_CASE_TEST_SUITE1
    FOREIGN KEY (TEST_SUITE_ID)
    REFERENCES TEST_SUITES (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_CASES_USERS1
    FOREIGN KEY (PRIMARY_OWNER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_CASES_USERS2
    FOREIGN KEY (SECONDARY_OWNER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_CASES_PROJECTS1
    FOREIGN KEY (PROJECT_ID)
    REFERENCES PROJECTS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE INDEX FK_TEST_CASE_SUITE_ASC ON TEST_CASES (TEST_SUITE_ID);
CREATE INDEX FK_TEST_CASE_PRIMARY_OWNER_ASC ON TEST_CASES (PRIMARY_OWNER_ID);
CREATE INDEX FK_TEST_CASE_SECONDARY_OWNER_ASC ON TEST_CASES (SECONDARY_OWNER_ID);
CREATE INDEX FK_TEST_CASES_PROJECTS_ASC ON TEST_CASES (PROJECT_ID);
CREATE INDEX TESTCASES_TEST_CLASS_INDEX ON TEST_CASES (TEST_CLASS);
CREATE INDEX TESTCASES_TEST_METHOD_INDEX ON TEST_CASES (TEST_METHOD);
CREATE UNIQUE INDEX TESTCASES_OWNERSHIP_UNIQUE ON TEST_CASES (PRIMARY_OWNER_ID, TEST_CLASS, TEST_METHOD);
CREATE TRIGGER update_timestamp_test_cases BEFORE INSERT OR UPDATE ON TEST_CASES
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS WORK_ITEMS;
CREATE TABLE IF NOT EXISTS WORK_ITEMS (
  ID SERIAL,
  JIRA_ID VARCHAR(45) NOT NULL,
  TYPE VARCHAR(45) NOT NULL DEFAULT 'TASK',
  HASH_CODE INT NULL,
  DESCRIPTION TEXT NULL,
  USER_ID INT NULL,
  TEST_CASE_ID INT NULL,
  KNOWN_ISSUE BOOLEAN NOT NULL DEFAULT FALSE,
  BLOCKER BOOLEAN NOT NULL DEFAULT FALSE,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_WORK_ITEMS_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_WORK_ITEMS_TEST_CASES1
    FOREIGN KEY (TEST_CASE_ID)
    REFERENCES TEST_CASES (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX WORK_ITEM_UNIQUE ON WORK_ITEMS (JIRA_ID, TYPE, HASH_CODE);
CREATE INDEX FK_WORK_ITEM_USER_ASC ON WORK_ITEMS (USER_ID);
CREATE INDEX FK_WORK_ITEM_TEST_CASE_ASC ON WORK_ITEMS (TEST_CASE_ID);
CREATE TRIGGER update_timestamp_work_items BEFORE INSERT OR UPDATE ON WORK_ITEMS
    FOR EACH ROW EXECUTE PROCEDURE update_timestamp();
CREATE INDEX WORK_ITEMS_CREATED_AT_INDEX ON WORK_ITEMS (CREATED_AT);



DROP TABLE IF EXISTS JOBS;
CREATE TABLE IF NOT EXISTS JOBS (
  ID SERIAL,
  USER_ID INT NULL,
  NAME VARCHAR(100) NOT NULL,
  JOB_URL VARCHAR(255) NOT NULL,
  JENKINS_HOST VARCHAR(255) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_JOBS_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX JOB_URL_UNIQUE ON JOBS (JOB_URL);
CREATE INDEX fk_JOBS_USERS1_idx ON JOBS (USER_ID);
CREATE TRIGGER update_timestamp_jobs BEFORE INSERT OR UPDATE ON JOBS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS VIEWS;
CREATE TABLE IF NOT EXISTS VIEWS (
  ID SERIAL,
  PROJECT_ID INT NULL,
  NAME VARCHAR(255) NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_VIEWS_PROJECTS1
    FOREIGN KEY (PROJECT_ID)
    REFERENCES PROJECTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_VIEWS_PROJECTS1_idx ON VIEWS (PROJECT_ID);
CREATE UNIQUE INDEX VIEW_NAME_UNIQUE ON VIEWS (NAME);
CREATE TRIGGER update_timestamp_views BEFORE INSERT OR UPDATE ON VIEWS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS JOB_VIEWS;
CREATE TABLE IF NOT EXISTS JOB_VIEWS (
  ID SERIAL,
  JOB_ID INT NOT NULL,
  VIEW_ID INT NOT NULL,
  ENV VARCHAR(255) NOT NULL,
  POSITION INT NOT NULL DEFAULT 0,
  SIZE INT NOT NULL DEFAULT 1,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_JOB_VIEWS_JOBS1
    FOREIGN KEY (JOB_ID)
    REFERENCES JOBS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_JOB_VIEWS_VIEWS1
    FOREIGN KEY (VIEW_ID)
    REFERENCES VIEWS(ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_JOB_VIEWS_JOBS1_idx ON JOB_VIEWS (JOB_ID);
CREATE INDEX fk_JOB_VIEWS_VIEWS1_idx ON JOB_VIEWS (VIEW_ID);
CREATE UNIQUE INDEX JOB_ID_ENV_UNIQUE ON JOB_VIEWS (JOB_ID, ENV);
CREATE TRIGGER update_timestamp_job_views BEFORE INSERT OR UPDATE ON JOB_VIEWS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_CONFIGS;
CREATE TABLE IF NOT EXISTS TEST_CONFIGS (
  ID SERIAL,
  URL VARCHAR(512) NULL,
  ENV VARCHAR(50) NULL,
  PLATFORM VARCHAR(30) NULL,
  PLATFORM_VERSION VARCHAR(30) NULL,
  BROWSER VARCHAR(30) NULL,
  BROWSER_VERSION VARCHAR(30) NULL,
  APP_VERSION VARCHAR(255) NULL,
  LOCALE VARCHAR(30) NULL,
  LANGUAGE VARCHAR(30) NULL,
  DEVICE VARCHAR(50) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE TRIGGER update_timestamp_test_configs BEFORE INSERT OR UPDATE ON TEST_CONFIGS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_RUNS;
CREATE TABLE IF NOT EXISTS TEST_RUNS (
  ID SERIAL,
  CI_RUN_ID VARCHAR(50) NULL,
  USER_ID INT,
  TEST_SUITE_ID INT NOT NULL,
  STATUS VARCHAR(20) NOT NULL,
  SCM_URL VARCHAR(255) NULL,
  SCM_BRANCH VARCHAR(100) NULL,
  SCM_COMMIT VARCHAR(100) NULL,
  CONFIG_XML TEXT NULL,
  WORK_ITEM_ID INT NULL,
  JOB_ID INT NOT NULL,
  BUILD_NUMBER INT NOT NULL,
  STARTED_BY VARCHAR(45) NULL,
  UPSTREAM_JOB_ID INT  NULL,
  UPSTREAM_JOB_BUILD_NUMBER INT NULL,
  PROJECT_ID INT NULL,
  CONFIG_ID INT NULL,
  KNOWN_ISSUE BOOLEAN NOT NULL DEFAULT FALSE,
  BLOCKER BOOLEAN NOT NULL DEFAULT FALSE,
  ENV VARCHAR(50) NULL,
  PLATFORM VARCHAR(30) NULL,
  APP_VERSION VARCHAR(255) NULL,
  STARTED_AT TIMESTAMP NULL,
  ELAPSED INT NULL,
  ETA INT NULL,
  COMMENTS TEXT NULL,
  SLACK_CHANNELS VARCHAR(255) NULL,
  REVIEWED BOOLEAN NOT NULL DEFAULT FALSE,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_RESULTS_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RESULTS_TEST_SUITES1
    FOREIGN KEY (TEST_SUITE_ID)
    REFERENCES TEST_SUITES (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RUNS_WORK_ITEMS1
    FOREIGN KEY (WORK_ITEM_ID)
    REFERENCES WORK_ITEMS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RUNS_JOBS1
    FOREIGN KEY (JOB_ID)
    REFERENCES JOBS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RUNS_JOBS2
    FOREIGN KEY (UPSTREAM_JOB_ID)
    REFERENCES JOBS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_RUNS_PROJECTS1
    FOREIGN KEY (PROJECT_ID)
    REFERENCES PROJECTS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT test_runs_test_configs_id_fk
    FOREIGN KEY (CONFIG_ID)
    REFERENCES TEST_CONFIGS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE INDEX FK_TEST_RUN_USER_ASC ON TEST_RUNS (USER_ID);
CREATE INDEX FK_TEST_RUN_TEST_SUITE_ASC ON TEST_RUNS (TEST_SUITE_ID);
CREATE INDEX fk_TEST_RUNS_WORK_ITEMS1_idx ON TEST_RUNS (WORK_ITEM_ID);
CREATE INDEX fk_TEST_RUNS_JOBS1_idx ON TEST_RUNS (JOB_ID);
CREATE INDEX fk_TEST_RUNS_JOBS2_idx ON TEST_RUNS (UPSTREAM_JOB_ID);
CREATE INDEX fk_TEST_RUNS_PROJECTS1_idx ON TEST_RUNS (PROJECT_ID);
CREATE INDEX TEST_RUNS_STARTED_AT_INDEX ON TEST_RUNS(STARTED_AT ASC NULLS LAST);
CREATE UNIQUE INDEX CI_RUN_ID_UNIQUE ON TEST_RUNS (CI_RUN_ID);
CREATE TRIGGER update_timestamp_test_runs BEFORE INSERT OR UPDATE ON TEST_RUNS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TESTS;
CREATE TABLE IF NOT EXISTS TESTS (
  ID SERIAL,
  CI_TEST_ID VARCHAR(50) NULL,
  NAME VARCHAR(255) NOT NULL,
  STATUS VARCHAR(20) NOT NULL,
  TEST_ARGS TEXT NULL,
  TEST_RUN_ID INT NOT NULL,
  TEST_CASE_ID INT NOT NULL,
  TEST_GROUP VARCHAR(255),
  MESSAGE TEXT NULL,
  MESSAGE_HASH_CODE INT NULL,
  START_TIME TIMESTAMP NULL,
  FINISH_TIME TIMESTAMP NULL,
  RETRY INT NOT NULL DEFAULT 0,
  TEST_CONFIG_ID INT NULL,
  KNOWN_ISSUE BOOLEAN NOT NULL DEFAULT FALSE,
  BLOCKER BOOLEAN NOT NULL DEFAULT FALSE,
  NEED_RERUN BOOLEAN NOT NULL DEFAULT TRUE,
  DEPENDS_ON_METHODS VARCHAR(255) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TESTS_TEST_CONFIGS1
    FOREIGN KEY (TEST_CONFIG_ID)
    REFERENCES TEST_CONFIGS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TESTS_TEST_RUNS1
    FOREIGN KEY (TEST_RUN_ID)
    REFERENCES TEST_RUNS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TESTS_TEST_CASES1
    FOREIGN KEY (TEST_CASE_ID)
    REFERENCES TEST_CASES (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE INDEX fk_TESTS_TEST_RUNS1_idx ON  TESTS (TEST_RUN_ID);
CREATE INDEX fk_TESTS_TEST_CASES1_idx ON  TESTS (TEST_CASE_ID);
CREATE INDEX fk_TESTS_TEST_CONFIGS1_idx ON TESTS (TEST_CONFIG_ID);
CREATE TRIGGER update_timestamp_tests BEFORE INSERT OR UPDATE ON TESTS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TAGS;
CREATE TABLE IF NOT EXISTS TAGS (
  ID SERIAL,
  NAME VARCHAR(50) NOT NULL,
  VALUE VARCHAR(255) NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
  CREATE UNIQUE INDEX TAGS_UNIQUE ON TAGS (NAME, VALUE);
  CREATE INDEX TAGS_NAME ON TAGS (NAME);
CREATE INDEX TAGS_VALUE ON TAGS (VALUE);
CREATE TRIGGER update_timestamp_tags BEFORE INSERT OR UPDATE ON TAGS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();

DROP TABLE IF EXISTS TEST_TAGS;
CREATE TABLE IF NOT EXISTS TEST_TAGS (
  ID SERIAL,
  TEST_ID INT NOT NULL,
  TAG_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TESTS_TEST_TAGS1
    FOREIGN KEY (TEST_ID)
    REFERENCES TESTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TAGS_TEST_TAGS1
    FOREIGN KEY (TAG_ID)
    REFERENCES TAGS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE INDEX fk_TESTS_TEST_TAGS1_idx ON  TEST_TAGS (TEST_ID);
CREATE INDEX fk_TAGS_TEST_TAGS1_idx ON  TEST_TAGS (TAG_ID);
CREATE UNIQUE INDEX TEST_TAGS_UNIQUE ON TEST_TAGS (TAG_ID, TEST_ID);
CREATE TRIGGER update_timestamp_test_tags BEFORE INSERT OR UPDATE ON TEST_TAGS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS USER_PREFERENCES;
CREATE TABLE IF NOT EXISTS USER_PREFERENCES (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  VALUE VARCHAR(255) NOT NULL ,
  USER_ID INT,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT user_preferences_users_id_fk
  FOREIGN KEY (USER_ID)
  REFERENCES USERS (ID)
  ON DELETE CASCADE
  ON UPDATE NO ACTION);
CREATE UNIQUE INDEX NAME_USER_ID_UNIQUE ON USER_PREFERENCES (NAME, USER_ID);
CREATE TRIGGER update_timestamp_user_preferences BEFORE INSERT OR UPDATE ON USER_PREFERENCES FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_ARTIFACTS;
CREATE TABLE IF NOT EXISTS TEST_ARTIFACTS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  LINK TEXT NOT NULL,
  EXPIRES_AT TIMESTAMP NULL,
  TEST_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_ARTIFACTS_TESTS1
    FOREIGN KEY (TEST_ID)
    REFERENCES TESTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_TEST_ARTIFACTS_TESTS1_idx ON TEST_ARTIFACTS (TEST_ID);
CREATE UNIQUE INDEX NAME_TEST_ID_UNIQUE ON TEST_ARTIFACTS (NAME, TEST_ID);
CREATE TRIGGER update_timestamp_test_artifacts BEFORE INSERT OR UPDATE ON TEST_ARTIFACTS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();



DROP TABLE IF EXISTS TEST_WORK_ITEMS;
CREATE TABLE IF NOT EXISTS TEST_WORK_ITEMS (
  ID SERIAL,
  TEST_ID INT NOT NULL,
  WORK_ITEM_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_WORK_ITEMS_TESTS1
    FOREIGN KEY (TEST_ID)
    REFERENCES TESTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_TEST_WORK_ITEMS_WORK_ITEMS1
    FOREIGN KEY (WORK_ITEM_ID)
    REFERENCES WORK_ITEMS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX TEST_WORK_ITEM_TEST_ID_WORK_ITEM_ID_UNIQUE ON TEST_WORK_ITEMS (TEST_ID, WORK_ITEM_ID);
CREATE INDEX fk_TEST_WORK_ITEMS_TESTS1_idx ON  TEST_WORK_ITEMS (TEST_ID);
CREATE INDEX fk_TEST_WORK_ITEMS_WORK_ITEMS1_idx ON  TEST_WORK_ITEMS (WORK_ITEM_ID);
CREATE TRIGGER update_timestamp_test_work_items BEFORE INSERT OR UPDATE ON TEST_WORK_ITEMS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS TEST_METRICS;
CREATE TABLE IF NOT EXISTS TEST_METRICS (
  ID SERIAL,
  OPERATION VARCHAR(127) NOT NULL,
  ELAPSED BIGINT NOT NULL,
  TEST_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_TEST_METRICS_TESTS1
    FOREIGN KEY (TEST_ID)
    REFERENCES TESTS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_TEST_METRICS_TESTS1_idx ON  TEST_METRICS (TEST_ID);
CREATE INDEX TEST_OPERATION ON  TEST_METRICS (OPERATION);
CREATE TRIGGER update_timestamp_test_metrics BEFORE INSERT OR UPDATE ON TEST_METRICS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS SETTINGS;
CREATE TABLE IF NOT EXISTS SETTINGS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  VALUE TEXT NULL,
  IS_ENCRYPTED BOOLEAN NULL DEFAULT FALSE,
  TOOL VARCHAR(255) NULL,
  FILE BYTEA NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX SETTING_UNIQUE ON SETTINGS (NAME);
CREATE TRIGGER update_timestamp_settings BEFORE INSERT OR UPDATE ON SETTINGS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS WIDGETS;
CREATE TABLE IF NOT EXISTS WIDGETS (
  ID SERIAL,
  TITLE VARCHAR(255) NOT NULL,
  DESCRIPTION VARCHAR(255) NULL,
  PARAMS_CONFIG TEXT NULL,
  LEGEND_CONFIG TEXT NULL,
  WIDGET_TEMPLATE_ID INT NULL,
  REFRESHABLE BOOLEAN NOT NULL DEFAULT false NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  TYPE VARCHAR(20) NULL,
  SQL TEXT NULL,
  MODEL TEXT NULL,
  PRIMARY KEY (ID),
  CONSTRAINT fk_WIDGETS_WIDGET_TEMPLATES1
    FOREIGN KEY (WIDGET_TEMPLATE_ID)
    REFERENCES management.WIDGET_TEMPLATES (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX WIDGETS_TITLE_WIDGET_TEMPLATE_ID_UINDEX ON WIDGETS (TITLE, WIDGET_TEMPLATE_ID);
CREATE TRIGGER update_timestamp_widgets BEFORE INSERT OR UPDATE ON WIDGETS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS DASHBOARDS;
CREATE TABLE IF NOT EXISTS DASHBOARDS (
  ID SERIAL,
  TITLE VARCHAR(255) NOT NULL,
  HIDDEN BOOLEAN NOT NULL DEFAULT FALSE,
  POSITION INT NOT NULL DEFAULT 0,
  EDITABLE BOOLEAN NOT NULL DEFAULT TRUE,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE INDEX TITLE_UNIQUE ON DASHBOARDS (TITLE);
CREATE TRIGGER update_timestamp_dashboards BEFORE INSERT OR UPDATE ON DASHBOARDS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS DASHBOARDS_WIDGETS;
CREATE TABLE IF NOT EXISTS DASHBOARDS_WIDGETS (
  ID SERIAL,
  DASHBOARD_ID INT NOT NULL,
  WIDGET_ID INT NOT NULL,
  POSITION INT NULL DEFAULT 0,
  SIZE INT NULL DEFAULT 1,
  LOCATION VARCHAR(255) NOT NULL DEFAULT '',
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_DASHBOARDS_WIDGETS_DASHBOARDS1
    FOREIGN KEY (DASHBOARD_ID)
    REFERENCES DASHBOARDS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_DASHBOARDS_WIDGETS_WIDGETS1
    FOREIGN KEY (WIDGET_ID)
    REFERENCES WIDGETS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_DASHBOARDS_WIDGETS_DASHBOARDS1_idx ON DASHBOARDS_WIDGETS (DASHBOARD_ID);
CREATE INDEX fk_DASHBOARDS_WIDGETS_WIDGETS1_idx ON DASHBOARDS_WIDGETS (WIDGET_ID);
CREATE UNIQUE INDEX DASHBOARD_WIDGET_UNIQUE ON DASHBOARDS_WIDGETS (DASHBOARD_ID, WIDGET_ID);
CREATE TRIGGER update_timestamp_dashboards_widgets BEFORE INSERT OR UPDATE ON DASHBOARDS_WIDGETS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS GROUPS;
CREATE TABLE IF NOT EXISTS GROUPS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  ROLE VARCHAR(255) NOT NULL,
  INVITABLE BOOLEAN NOT NULL DEFAULT TRUE,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX GROUP_UNIQUE ON GROUPS (NAME);
CREATE TRIGGER update_timestamp_groups BEFORE INSERT OR UPDATE ON GROUPS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS USER_GROUPS;
CREATE TABLE IF NOT EXISTS USER_GROUPS (
  ID SERIAL,
  GROUP_ID INT NOT NULL,
  USER_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_USER_GROUPS_GROUPS1
    FOREIGN KEY (GROUP_ID)
    REFERENCES GROUPS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_USER_GROUPS_USERS1
    FOREIGN KEY (USER_ID)
    REFERENCES USERS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_USER_GROUPS_GROUPS1_idx ON USER_GROUPS (GROUP_ID);
CREATE INDEX fk_USER_GROUPS_USERS1_idx ON USER_GROUPS (USER_ID);
CREATE UNIQUE INDEX USER_GROUP_UNIQUE ON USER_GROUPS (USER_ID, GROUP_ID);
CREATE TRIGGER update_timestamp_user_groups BEFORE INSERT OR UPDATE ON USER_GROUPS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS PERMISSIONS;
CREATE TABLE IF NOT EXISTS PERMISSIONS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  BLOCK VARCHAR(50) NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
CREATE UNIQUE INDEX PERMISSION_UNIQUE ON PERMISSIONS (NAME);
CREATE TRIGGER update_timestamp_permissions BEFORE INSERT OR UPDATE ON PERMISSIONS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS GROUP_PERMISSIONS;
CREATE TABLE IF NOT EXISTS GROUP_PERMISSIONS (
  ID SERIAL,
  GROUP_ID INT NOT NULL,
  PERMISSION_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_GROUP_PERMISSIONS_GROUPS1
    FOREIGN KEY (GROUP_ID)
    REFERENCES GROUPS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_GROUP_PERMISSIONS_PERMISSIONS1
    FOREIGN KEY (PERMISSION_ID)
    REFERENCES PERMISSIONS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_GROUP_PERMISSIONS_GROUPS1_idx ON GROUP_PERMISSIONS (GROUP_ID);
CREATE INDEX fk_GROUP_PERMISSIONS_PERMISSIONS1_idx ON GROUP_PERMISSIONS (PERMISSION_ID);
CREATE UNIQUE INDEX GROUP_PERMISSION_UNIQUE ON GROUP_PERMISSIONS (PERMISSION_ID, GROUP_ID);
CREATE TRIGGER update_timestamp_group_premissions BEFORE INSERT OR UPDATE ON GROUP_PERMISSIONS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS DASHBOARD_ATTRIBUTES;
CREATE TABLE IF NOT EXISTS DASHBOARD_ATTRIBUTES (
  ID SERIAL,
  KEY VARCHAR(255) NOT NULL,
  VALUE VARCHAR(255) NOT NULL,
  DASHBOARD_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_DASHBOARD_ATTRIBUTES_DASHBOARDS1
    FOREIGN KEY (DASHBOARD_ID)
    REFERENCES DASHBOARDS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
CREATE INDEX fk_DASHBOARD_ATTRIBUTES_DASHBOARDS1_idx ON DASHBOARD_ATTRIBUTES (DASHBOARD_ID);
CREATE UNIQUE INDEX DASHBOARD_KEY_UNIQUE ON DASHBOARD_ATTRIBUTES (KEY, DASHBOARD_ID);
CREATE TRIGGER update_timestamp_dashboard_attributes BEFORE INSERT OR UPDATE ON DASHBOARD_ATTRIBUTES FOR EACH ROW EXECUTE PROCEDURE update_timestamp();

DROP TABLE IF EXISTS INVITATIONS;
CREATE TABLE IF NOT EXISTS INVITATIONS (
  ID SERIAL,
  EMAIL VARCHAR(50) NOT NULL,
  TOKEN VARCHAR(255) NOT NULL,
  STATUS VARCHAR(50) NOT NULL,
  USER_ID INT NOT NULL,
  GROUP_ID INT NOT NULL,
  SOURCE VARCHAR(20) NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID) ,
  CONSTRAINT fk_INVITATIONS_USERS1
  FOREIGN KEY (USER_ID)
  REFERENCES USERS (ID)
  ON DELETE CASCADE
  ON UPDATE NO ACTION,
  CONSTRAINT fk_INVITATIONS_GROUPS1
  FOREIGN KEY (GROUP_ID)
  REFERENCES GROUPS (ID)
  ON DELETE CASCADE
  ON UPDATE NO ACTION);
CREATE INDEX fk_INVITATIONS_USERS1_idx ON INVITATIONS (USER_ID);
CREATE INDEX fk_INVITATIONS_GROUPS1_idx ON INVITATIONS (GROUP_ID);
CREATE UNIQUE INDEX EMAIL_UNIQUE ON INVITATIONS (EMAIL);
CREATE UNIQUE INDEX TOKEN_UNIQUE ON INVITATIONS (TOKEN);
CREATE TRIGGER update_timestamp_invitations BEFORE INSERT OR UPDATE ON INVITATIONS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS FILTERS ;

CREATE TABLE IF NOT EXISTS FILTERS (
  ID SERIAL,
  NAME VARCHAR(50) NOT NULL,
  DESCRIPTION TEXT NULL,
  SUBJECT TEXT NOT NULL,
  PUBLIC_ACCESS BOOLEAN NOT NULL DEFAULT FALSE,
  USER_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
  CREATE UNIQUE INDEX FILTERS_NAME_PUBLIC_UNIQUE ON FILTERS(NAME) WHERE PUBLIC_ACCESS = TRUE;
  CREATE UNIQUE INDEX FILTERS_NAME_USER_ID_PUBLIC_ACCESS_PRIVATE_UNIQUE ON FILTERS(NAME, USER_ID, PUBLIC_ACCESS) WHERE PUBLIC_ACCESS = FALSE;
  CREATE TRIGGER update_timestamp_filters BEFORE INSERT OR UPDATE ON FILTERS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


  DROP TABLE IF EXISTS SCM ;

CREATE TABLE IF NOT EXISTS SCM (
  ID SERIAL,
  NAME VARCHAR(50) NOT NULL,
  LOGIN VARCHAR(255) NULL,
  ACCESS_TOKEN VARCHAR(255) NOT NULL,
  ORGANIZATION VARCHAR(255) NULL,
  REPO VARCHAR(255) NULL,
  REPOSITORY_URL VARCHAR(255) NULL,
  USER_ID INT NULL,
  AVATAR_URL VARCHAR(255) NULL,
  API_VERSION VARCHAR(255) NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID));
  CREATE TRIGGER update_timestamp_scm BEFORE INSERT OR UPDATE ON SCM FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


    DROP TABLE IF EXISTS LAUNCHERS ;

CREATE TABLE IF NOT EXISTS LAUNCHERS (
  ID SERIAL,
  NAME VARCHAR(255) NOT NULL,
  MODEL TEXT NOT NULL,
  SCM_ID INT NOT NULL,
  JOB_ID INT NULL,
  AUTO_SCAN BOOLEAN NOT NULL DEFAULT FALSE,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_LAUNCHERS_SCM1
    FOREIGN KEY (SCM_ID)
    REFERENCES SCM (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT fk_LAUNCHERS_JOBS1
    FOREIGN KEY (JOB_ID)
    REFERENCES JOBS (ID)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
  CREATE TRIGGER update_timestamp_launchers BEFORE INSERT OR UPDATE ON LAUNCHERS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS LAUNCHER_PRESETS;
CREATE TABLE IF NOT EXISTS LAUNCHER_PRESETS (
  ID SERIAL,
  NAME VARCHAR(50) NOT NULL,
  REFERENCE VARCHAR(20) NOT NULL,
  PARAMS TEXT NULL,
  LAUNCHER_ID INT NOT NULL,
  MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (ID),
  CONSTRAINT fk_LAUNCHER_PRESET_LAUNCHERS1
    FOREIGN KEY (LAUNCHER_ID)
    REFERENCES LAUNCHERS (ID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
CREATE UNIQUE INDEX LAUNCHER_PRESET_LAUNCHER_ID_NAME_UNIQUE ON LAUNCHER_PRESETS (NAME, LAUNCHER_ID);
CREATE UNIQUE INDEX LAUNCHER_PRESET_REFERENCE_UNIQUE ON LAUNCHER_PRESETS (REFERENCE);
CREATE TRIGGER update_timestamp_launcher_presets BEFORE INSERT OR UPDATE ON LAUNCHER_PRESETS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


DROP TABLE IF EXISTS LAUNCHER_CALLBACKS;
CREATE TABLE IF NOT EXISTS LAUNCHER_CALLBACKS (
    ID SERIAL,
    CI_RUN_ID VARCHAR(50) NOT NULL,
    URL VARCHAR(255) NOT NULL,
    REFERENCE VARCHAR(20) NOT NULL,
    LAUNCHER_PRESET_ID INT NOT NULL,
    MODIFIED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CREATED_AT TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ID),
    CONSTRAINT fk_LAUNCHER_CALLBACK_LAUNCHER_PRESETS1
        FOREIGN KEY (LAUNCHER_PRESET_ID)
            REFERENCES LAUNCHER_PRESETS (ID)
            ON DELETE NO ACTION
            ON UPDATE NO ACTION);
CREATE UNIQUE INDEX LAUNCHER_CALLBACK_CI_RUN_ID_UNIQUE ON LAUNCHER_CALLBACKS (CI_RUN_ID);
CREATE UNIQUE INDEX LAUNCHER_CALLBACK_REFERENCE_UNIQUE ON LAUNCHER_CALLBACKS (REFERENCE);
CREATE TRIGGER update_timestamp_launcher_callback BEFORE INSERT OR UPDATE ON LAUNCHER_CALLBACKS FOR EACH ROW EXECUTE PROCEDURE update_timestamp();


CREATE OR REPLACE FUNCTION check_version(INTEGER) RETURNS VOID AS $$
DECLARE CURRENT_VERSION SETTINGS.VALUE%TYPE;
BEGIN
  CURRENT_VERSION := (SELECT VALUE FROM SETTINGS WHERE NAME = 'LAST_ALTER_VERSION');
  IF (SELECT to_number(CURRENT_VERSION, '9999') + 1 != $1 AND CURRENT_VERSION != '0') THEN
    RAISE EXCEPTION 'Alter table can not be executed. Expected version is "%". Actual version is "%".', to_number(CURRENT_VERSION, '9999') + 1, $1;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_version(INT) RETURNS VOID AS $$
DECLARE CURRENT_VERSION SETTINGS.VALUE%TYPE;
BEGIN
  CURRENT_VERSION := to_char($1, '9999');
  UPDATE SETTINGS SET VALUE = CURRENT_VERSION WHERE NAME = 'LAST_ALTER_VERSION';
END;
$$ LANGUAGE plpgsql;
