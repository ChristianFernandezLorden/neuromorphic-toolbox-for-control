import xml.etree.ElementTree as ET

github_link = "https://github.com/ChristianFernandezLorden/neuromorphic-toolbox-for-control"
mathworks_link = "https://nl.mathworks.com/matlabcentral/fileexchange/180432-neuromorphic-toolbox-for-control"

# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Neuromorphic Toolbox for Control'
copyright = '2025-%Y, Université de Liège'
author = 'Christian Fernandez Lorden'
version = (ET.parse("../../toolbox_package/neuromorphic-toolbox-for-control.prj").getroot().findall('./configuration/param.version')[0].text)
release = version

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.duration',
    'sphinx_togglebutton',
    'sphinxcontrib.bibtex',
    'sphinx_design',
]

templates_path = ['_templates']
exclude_patterns = []

bibtex_bibfiles = ['refs.bib']


html_title = "Neuromorphic Toolbox for Control"
html_short_title = "NTC"

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_book_theme'
html_static_path = ['_static']

html_js_files = [
    ("js/custom-icons.js", {"defer": "defer"}),
]

branch = version

html_theme_options = {
    "path_to_docs": "docs/source",
    "repository_url": github_link,
    "repository_branch": branch,
    "use_edit_page_button": True,
    "use_source_button": True,
    "use_issues_button": True,
    "use_download_button": True,
    
    "collapse_navbar": False,
    "home_page_in_toc": False,
    "icon_links": [
        {
            "name": "GitHub",
            "url":  github_link,
            "icon": "fa-brands fa-github",
            "type": "fontawesome",
        },
        {
            "name": "MathWorks File Exchange",
            "url":  mathworks_link,
            "icon": "fa-custom fa-mathworks",
            "type": "fontawesome",
        },
        {
            "name": "Laboratory",
            "url": "https://www.neuroengineering.uliege.be/cms/c_11384013/en/neuroengineering-laboratory",
            "icon": "fa-solid fa-building-columns",
            "type": "fontawesome",
        },
    ],
}


html_sidebars = {
    "**": [
        "navbar-logo.html",
        "icon-links.html",
        "search-button-field.html",
        "sbt-sidebar-nav.html",
    ]
}


rst_prolog = """
.. |matlab| replace:: MATLAB®
.. |simulink| replace:: Simulink®
.. |matlab_simulink| replace:: MATLAB® and Simulink®
.. |mathworks| replace:: MathWorks®
.. |github| replace:: GitHub
.. |mathworks-file-exchange| replace:: MathWorks® File Exchange
.. |fa-github| raw:: html

    <i class="fa-brands fa-github"></i>
    
.. |fa-mathworks| raw:: html

    <i class="fa-custom fa-mathworks"></i>

.. |github-link| raw:: html

    <a href="""+github_link+"""><i class="fa-brands fa-github"></i>GitHub</a>

.. |mathworks-file-exchange-link| raw:: html

    <a href="""+mathworks_link+"""><i class="fa-custom fa-mathworks"></i>MathWorks® File Exchange</a>
    
"""