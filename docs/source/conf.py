import subprocess
import xml.etree.ElementTree as ET

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

html_theme_options = {
    "repository_url": "https://github.com/ChristianFernandezLorden/neuromorphic-toolbox-for-control",
    "use_repository_button": True,
    "collapse_navbar": False,
    "home_page_in_toc": False,
    "icon_links": [
        {
            "name": "GitHub",
            "url": "https://github.com/executablebooks/sphinx-book-theme",
            "icon": "fa-brands fa-github",
        },
        {
            "name": "MathWorks File Exchange",
            "url": "https://nl.mathworks.com/matlabcentral/fileexchange/180432-neuromorphic-toolbox-for-control",
            "icon": "_static/mathworks-logo.png",
            "type": "local",
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