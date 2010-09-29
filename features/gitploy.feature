Feature: gitploy

  Scenario Outline: Missing options
    Given an invalid configuration file
    When I run "gitploy <arguments>"
    Then the output should contain:
      """
      The following configuration options are missing for the 'staging' stage: path, user, host
      """
    Examples:
      | arguments     |
      | staging setup |
      | staging       |

  Scenario Outline: Pretend execution
    Given a valid configuration file
    When I run "gitploy <arguments>"
    Then the output should contain "(pretend)"
    Examples:
      | arguments               |
      | staging setup --pretend |
      | staging setup -p        |
      | staging --pretend       |
      | staging -p              |

  Scenario: Setup on staging
    Given a valid configuration file
    When I run "gitploy staging setup --pretend"
    Then the output should contain "Setup local"
    And the output should contain "ssh staging@staging.gitploy.foo"
    And the output should contain "mkdir -p /var/www/fooapp"
    And the output should contain "cd /var/www/fooapp && git init"
    But the output should not contain "Deploy local"
    And the output should not contain "ssh production@gitploy.foo"
    And the output should not contain "bundle install"

  Scenario: Deploy on staging
    Given a valid configuration file
    When I run "gitploy staging --pretend"
    Then the output should contain "git push"
    And the output should contain "Deploy local"
    And the output should contain "cd /var/www/fooapp"
    And the output should contain "git reset --hard"
    But the output should not contain "Setup local"
    And the output should not contain "ssh production@gitploy.foo"

  Scenario: Setup on production
    Given a valid configuration file
    When I run "gitploy production setup --pretend"
    Then the output should contain "Setup local"
    And the output should contain "production@gitploy.foo"
    But the output should not contain "Deploy local"
    And the output should not contain "staging@staging.gitploy.foo"
    And the output should not contain "git push"

  Scenario: Deploy on production
    Given a valid configuration file
    When I run "gitploy production --pretend"
    Then the output should contain "Deploy local"
    And the output should contain "production@gitploy.foo"
    And the output should contain "git push"
    But the output should not contain "Setup local"
    And the output should not contain "staging@staging.gitploy.foo"
