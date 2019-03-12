Feature: Home page

  Scenario: Home page for the site is the Data page
    When a user visits the home page
    Then they are on the Data page

  Scenario: Data page results are ordered correctly
    When a user visits the Data page
    Then they see a list of datasets
    And the datasets are ordered by last modified
