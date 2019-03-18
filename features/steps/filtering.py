from behave import *
from selenium.webdriver.common.by import By

use_step_matcher("re")


@step("they select a publisher")
def step_impl(context):
    """
    :type context: behave.runner.Context

    """
    context.pub_name = 'Joint Nature Conservation Committee'
    facets = context.driver.find_element_by_class_name('nav-facet')
    link = facets.find_element_by_xpath('//a[@title="{}"]'.format(context.pub_name))
    link.click()


@then("they see a list of search results")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    assert len(context.driver.find_elements_by_class_name('dataset-item')) > 0


@step("the search results are published by that publisher")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    for pub in context.driver.find_elements_by_class_name('dataset-publisher-heading'):
        assert pub.find_element_by_tag_name('a').text == context.pub_name


@step("they select a data format")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.dataset_format = 'CSV'
    facets = context.driver.find_element_by_class_name('nav-facet')
    link = facets.find_element_by_xpath('//a[@title="{}"]'.format(context.dataset_format))
    link.click()


@step("the search results are available with that data type")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    for res in context.driver.find_elements_by_class_name('mdf-dataset-resources'):
        labels = [x.text for x in res.find_elements_by_class_name('label')]
        assert context.dataset_format in labels


@step("they select a license")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.dataset_license = 'UK Open Government Licence (OGL)'
    facets = context.driver.find_element_by_class_name('nav-facet')
    link = facets.find_element_by_xpath('//a[@title="{}"]'.format(context.dataset_license))
    link.click()


@step("the search results are licensed under that license")
def step_impl(context):
    """
    :type context: behave.runner.Context

    """
    urls = []
    for ds in context.driver.find_elements_by_class_name('dataset-heading'):
        urls.append(ds.find_element_by_tag_name('a').get_attribute('href'))

    for url in urls:
        context.driver.get(url)
        license = context.driver.find_element_by_xpath('//*[@id="content"]/div[3]/aside/div/div[2]/section/div/p/a[1]')
        assert license.text == context.dataset_license


@step("they select to view private datasets")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    facets = context.driver.find_element_by_class_name('nav-facet')
    link = facets.find_element_by_xpath('//a[@title="Private datasets"]')
    link.click()


@step("the search results are marked as private")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    for dataset in context.driver.find_elements_by_class_name('dataset-item'):
        assert dataset.find_elements_by_class_name('private-label')


@step("they select to view core reference data")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    facets = context.driver.find_element_by_class_name('nav-facet')
    link = facets.find_element_by_xpath('//a[@title="Reference Data"]')
    link.click()


@step("the search results are marked as reference data")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    # TODO: We don't have any reference data just yet
    pass


@step("they select to view GDPR data")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    facets = context.driver.find_element_by_class_name('nav-facet')
    link = facets.find_element_by_xpath('//a[@title="GDPR"]')
    link.click()


@step("the search results are marked as GDPR")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    # TODO: We don't have any GDPR data just yet
    pass
