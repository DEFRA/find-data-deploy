Feature: Filtering

  Scenario: User filters by a single publisher
    When a user visits the Data page
    And they select a publisher
    Then they see a list of search results
    And the search results are published by that publisher

  Scenario: User filters by a single data format
    When a user visits the Data page
    And they select a data format
    Then they see a list of search results
    And the search results are available with that data type

  Scenario: User filters by a single license
    When a user visits the Data page
    And they select a license
    Then they see a list of search results
    And the search results are licensed under that license

# FIXME: Need to add a private dataset to the fixtures
#  Scenario: User filters by private data
#    When a user visits the Data page
#    And they select to view private datasets
#    Then they see a list of search results
#    And the search results are marked as private

# FIXME: There are no reference datasets on the platform at the moment
#  Scenario: User filters by core reference data
#    When a user visits the Data page
#    And they select to view core reference data
#    Then they see a list of search results
#    And the search results are marked as reference data

# FIXME: There are no GDPR datasets on the platform at the moment
#  Scenario: User filters by GDPR data
#    When a user visits the Data page
#    And they select to view GDPR data
#    Then they see a list of search results
#    And the search results are marked as GDPR
