import requests
from behave import *
from dateutil.parser import parse
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

use_step_matcher("re")


@when("a user views the (?P<report>.+) report")
def step_impl(context, report):
    """
    :type context: behave.runner.Context
    :type report: str
    """
    context.driver.get('{}/report/{}'.format(context.base_url, report))


@then("they can see the report's description")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    description = context.driver.find_element_by_xpath('//*[@id="content"]/div[3]/div/div[2]').text
    assert description != ''


@then("they can see graphs of the results")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    WebDriverWait(context.driver, 10).until(
        EC.presence_of_element_located((By.TAG_NAME, 'svg'))
    )
    publisher_count = len(context.driver.find_elements_by_class_name('publisher-chart'))
    graph_count = len(context.driver.find_elements_by_tag_name('svg'))
    assert publisher_count == graph_count


@given("an admin user")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.get(context.base_url + '/user/_logout')
    context.driver.get(context.base_url + '/user/login')
    username = context.driver.find_element_by_id('field-login')
    username.clear()
    username.send_keys('admin')
    password = context.driver.find_element_by_id('field-password')
    password.clear()
    password.send_keys('correct horse battery staple')
    password.send_keys(Keys.RETURN)


@then("they can refresh the report manually")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    assert(len(context.driver.find_elements_by_id('regen')) == 1)


@step("they download the data as JSON")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.report_url = context.driver.find_element_by_xpath(
        '//*[@id="content"]/div[3]/div/div[1]/a[2]'
    ).get_attribute('href')


@then("they receive data in JSON format")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    resp = requests.get(context.report_url)
    assert resp.headers['Content-Type'] == 'application/json'


@step("they download the data as CSV")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.report_url = context.driver.find_element_by_xpath(
        '//*[@id="content"]/div[3]/div/div[1]/a[1]'
    ).get_attribute('href')


@then("they receive data in CSV format")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    resp = requests.get(context.report_url)
    assert resp.headers['Content-Type'] == 'application/csv'


@then("they can see when the report was generated")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    content = context.driver.find_element_by_xpath('//*[@id="content"]/div[3]/div/h1/small').text
    try:
        parse(content, fuzzy=True)
    except ValueError:
        raise AssertionError('No valid date found')
