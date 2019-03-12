Feature: Ordering

  Scenario: User orders search results by name
    When a user visits the Data page
    And they reorder the results by name ascending
    Then they see a list of datasets
    And the datasets are ordered ascending by title

  Scenario: User orders search results by name descending
    When a user visits the Data page
    And they reorder the results by name descending
    Then they see a list of datasets
    And the datasets are ordered descending by title

  Scenario: User orders search results by last modified
    When a user visits the Data page
    And they reorder the results by last modified
    Then they see a list of datasets
    And the datasets are ordered by last modified
