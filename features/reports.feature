Feature: Reports

  Scenario Outline: User can see information text about a report
    When a user views the <report> report
    Then they can see the report's description
    Examples: Reports
      | report     |
      | publishing |
      | access     |
      | broken     |
      | quality    |

  Scenario Outline: User can see graphs on some reports
    When a user views the <report> report
    Then they can see graphs of the results
    Examples: Reports with graphs
      | report          |
      | publishing      |
      | access          |

# FIXME: Need to create an admin user programatically
#  Scenario Outline: Admin users can refresh the report manually
#    Given an admin user
#    When a user views the <report> report
#    Then they can refresh the report manually
#    Examples: Reports
#      | report     |
#      | publishing |
#      | access     |
#      | broken     |
#      | quality    |

  Scenario Outline: Users can download the report data as JSON
    When a user views the <report> report
    And they download the data as JSON
    Then they receive data in JSON format
    Examples: Reports
      | report     |
      | publishing |
      | access     |
      | broken     |
      | quality    |

  Scenario Outline: Users can download the report data as CSV
    When a user views the <report> report
    And they download the data as CSV
    Then they receive data in CSV format
    Examples: Reports
      | report     |
      | publishing |
      | access     |
      | broken     |
      | quality    |

  Scenario Outline: Users can see when the report was generated
    When a user views the <report> report
    Then they can see when the report was generated
    Examples: Reports
      | report     |
      | publishing |
      | access     |
      | broken     |
      | quality    |
