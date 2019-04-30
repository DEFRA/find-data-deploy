# encoding: utf-8
from pprint import pprint

from behave import *
from selenium.webdriver.support.select import Select

use_step_matcher("re")


@step("they reorder the results by name ascending")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    select = Select(context.driver.find_element_by_id('dataset-sort'))
    select.select_by_visible_text('Name Ascending')


@step("the datasets are ordered ascending by title")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    datasets = []
    for dataset in context.driver.find_elements_by_class_name('dataset-heading'):
        datasets.append(dataset.find_elements_by_tag_name('a')[0].text.lower().split(' ')[0])
    sorted_datasets = sorted(datasets)
    for i, ds in enumerate(datasets):
        assert ds == sorted_datasets[i], '{} != {}'.format(ds, sorted_datasets[i])


@step("they reorder the results by name descending")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    select = Select(context.driver.find_element_by_id('dataset-sort'))
    select.select_by_visible_text('Name Descending')


@step("the datasets are ordered descending by title")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    datasets = []
    for dataset in context.driver.find_elements_by_class_name('dataset-heading'):
        datasets.append(dataset.find_elements_by_tag_name('a')[0].text.lower().split(' ')[0])

    reversed_datasets = list(reversed(sorted(datasets)))
    for i, ds in enumerate(sorted(datasets)):
        assert ds == reversed_datasets[len(reversed_datasets) - 1 - i], '{} != {}'.format(
            ds,
            reversed_datasets[-i]
        )


@step("they reorder the results by last modified")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    select = Select(context.driver.find_element_by_id('dataset-sort'))
    select.select_by_visible_text('Last Modified')
