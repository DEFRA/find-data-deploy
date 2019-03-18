Feature: Publishers

  Scenario: Search for a publisher by name
    When a user visits the Publishers page
    And they search for a publisher's name
    Then they see a list of publishers
    And they can see the publisher's name
    And they can see the publisher's acronym
    And they can see the publisher's publication count

  Scenario: Search for a publisher by acronym
    When a user visits the Publishers page
    And they search for a publisher's acronym
    Then they see a list of publishers
    And they can see the publisher's name
    And they can see the publisher's acronym
    And they can see the publisher's publication count

  Scenario: Filter publishers by first letter
    When a user visits the Publishers page
    And they select a letter to filter by
    Then they see a list of publishers
    And the publishers start with the letter

  Scenario: See the datasets a publisher has published
    When a user visits the Publishers page
    And they select a publisher from the results
    Then they see a list of search results
    And the search results are published by the publisher
