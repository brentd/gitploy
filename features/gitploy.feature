Feature: gitploy

  Scenario Outline: Missing options
    Given a file named "config/deploy.rb" with:
      """
      require 'gitploy/script'
      configure do |c|
        stage :staging do
        end
      end
      """
    When I run "gitploy <arguments>"
    Then the output should contain:
      """
      The following configuration options are missing for the 'staging' stage: repo, path, user, host
      """
    Examples:
      | arguments     |
      | staging setup |
      | staging       |
