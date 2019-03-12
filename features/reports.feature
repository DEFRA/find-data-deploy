Feature: Reports

  Scenario: User can see information text about a report
    When a user views the report
    Then they can see the report's description

  Scenario Outline: User can see graphs on some reports
    When a user views the report on <topic>
    Then they can see graphs of the results

    Examples: Reports with graphs
      | topic           |
      | Publishing      |
      | Access          |

  Scenario: Admin users can refresh the report manually
    Given an admin user
    When a user views the report
    Then they can refresh the report manually

  Scenario: Users can download the report data as JSON
    When a user views the report
    And they download the data as JSON
    Then they receive data in JSON format

  Scenario: Users can download the report data as CSV
    When a user views the report
    And they download the data as CSV
    Then they receive data in CSV format

  Scenario: Users can see when the report was generated
    When a user views the report
    Then they can see when the report was generated
