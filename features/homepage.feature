Feature: Home page

  Scenario: Home page for the site is the home page
    When a user visits the home page
    Then they are on the home page

  Scenario: Data page results are ordered correctly
    When a user visits the Data page
    Then they see a list of datasets
    And the search results are ordered by relevance
