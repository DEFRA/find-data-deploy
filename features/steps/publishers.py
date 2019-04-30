from behave import *

use_step_matcher("re")


@when("a user visits the Publishers page")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.get(context.base_url + '/publisher')


@step("they search for a publisher's name")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    input = context.driver.find_element_by_xpath('//*[@id="dataset-search-form"]/div/input')
    input.clear()
    input.send_keys('defra')
    form = context.driver.find_element_by_id('dataset-search-form')
    form.find_element_by_tag_name('button').click()
    context.expected_search_results = 1


@then("they see a list of publishers")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    num_results = len(context.driver.find_elements_by_class_name('org-item'))
    assert num_results == context.expected_search_results, \
        '{} != {}'.format(num_results, context.expected_search_results)


@step("they can see the publisher's name")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    publishers = []
    for item in context.driver.find_elements_by_class_name('org-item'):
        publishers.append(item.find_elements_by_tag_name('p')[0].text)
    assert '' not in publishers


@step("they can see the publisher's acronym")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    publishers = []
    for item in context.driver.find_elements_by_class_name('org-item'):
        publishers.append(item.find_elements_by_tag_name('p')[1].text)
    assert '' not in publishers


@step("they can see the publisher's publication count")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    for item in context.driver.find_elements_by_class_name('org-item'):
        p = item.find_elements_by_tag_name('p')[2]
        count = p.find_element_by_tag_name('strong').text
        assert str(count).isdigit()


@step("they search for a publisher's acronym")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    input = context.driver.find_element_by_xpath('//*[@id="dataset-search-form"]/div/input')
    input.clear()
    input.send_keys('defra')
    form = context.driver.find_element_by_id('dataset-search-form')
    form.find_element_by_tag_name('button').click()
    context.expected_search_results = 1


@step("they select a letter to filter by")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.find_element_by_xpath('//a[@href="?startswith=d&"]').click()
    context.expected_search_results = 1


@step("the publishers start with the letter")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    for item in context.driver.find_elements_by_class_name('org-item'):
        assert item.find_elements_by_tag_name('p')[0].text.lower().startswith('d')


@step("they select a publisher from the results")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.find_element_by_xpath('//a[@href="/organization/defra"]').click()


@step("the search results are published by the publisher")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    for item in context.driver.find_elements_by_class_name('dataset-publisher-heading'):
        assert item.find_element_by_tag_name('a').text == 'Department for Environment, Food & Rural Affairs'


