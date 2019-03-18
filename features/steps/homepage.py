from behave import *
from selenium.webdriver.support.select import Select
from dateutil.parser import parse

use_step_matcher("re")


@when("a user visits the home page")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.get(context.base_url)


@then("they are on the Data page")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    assert context.driver.current_url == context.base_url + '/dataset'


@when("a user visits the Data page")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.get(context.base_url + '/dataset')


@then("they see a list of datasets")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    assert len(context.driver.find_elements_by_class_name('dataset-item')) > 0


@step("the datasets are ordered by last modified")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    sort_select = Select(context.driver.find_element_by_id('dataset-sort'))
    option = sort_select.first_selected_option
    assert option.text == 'Last Modified'

    dates = []
    for modified in context.driver.find_elements_by_class_name('mdf-dataset-modified'):
        dates.append(parse(modified.find_element_by_tag_name('strong').text))
    reversed_dates = list(reversed(sorted(dates)))
    assert len([i for i, j in zip(dates, reversed_dates) if i != j]) == 0
