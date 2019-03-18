Feature: Viewing datasets

  Scenario: User can see key information on dataset
    Given a dataset
    When a user visits the page about the dataset
    Then they see the dataset title
    And they see the dataset description
    And they see the dataset publisher
    And they see the dataset license

  Scenario: User can see bounding box of geospatial data
    Given a dataset that is geospatial
    When a user visits the page about the dataset
    Then they see the dataset bounding box

  Scenario: User can see datasets that are similar
    Given a dataset
    When a user visits the page about the dataset
    And they choose to see more like this
    Then they can see datasets that are similar to the dataset

  Scenario: User can preview datasets
    Given a dataset with CSV resource
    When a user visits the page about the dataset
    And they choose to preview the data
    Then they can see a table view of the data
