import os
import xml.etree.ElementTree as ET

github_link = "https://github.com/ChristianFernandezLorden/neuromorphic-toolbox-for-control"
mathworks_link = "https://nl.mathworks.com/matlabcentral/fileexchange/180432-neuromorphic-toolbox-for-control"
lab_link = "https://www.neuroengineering.uliege.be/cms/c_11384013/en/neuroengineering-laboratory"
if 'READTHEDOCS' in os.environ:
    doc_link = os.environ['READTHEDOCS_CANONICAL_URL']
else:
    doc_link = "https://neuromorphic-toolbox-for-control.readthedocs.io/en/latest/"
    

# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'NeuroCont'
copyright = '2025-%Y, Université de Liège'
author = 'Christian Fernandez Lorden'
if 'READTHEDOCS' in os.environ:
    version = os.environ['READTHEDOCS_VERSION_NAME']
else:
    version = (ET.parse("../../toolbox_package/NeuroCont.prj").getroot().findall('./configuration/param.version')[0].text)
release = version

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    'sphinx.ext.duration',
    'sphinxcontrib.bibtex',
    'sphinx_design',
    'sphinx.ext.autodoc', 
    'sphinxcontrib.matlab',
    'sphinx.ext.napoleon',
    'sphinx_autodoc_typehints',
    'sphinx_copybutton'
]
napoleon_numpy_docstring = True
napoleon_custom_sections = [('Inputs','params_style'),('Input','params_style'),
                            ('Outputs','params_style'),('Output','params_style'),
                            ('Required Inputs','params_style'),('Required Input','params_style'),
                            'Authors',('Optional Inputs','params_style'),
                            ('Optional Input','params_style'),('Description','params_style'),'Name-Value Inputs']
this_dir = os.path.dirname(os.path.abspath(__file__))
matlab_src_dir = os.path.abspath(os.path.join(this_dir, '../../code'))
primary_domain = 'mat'
napoleon_use_param = True

napoleon_use_admonition_for_notes = True


templates_path = ['_templates']
exclude_patterns = []

bibtex_bibfiles = ['refs.bib']


html_title = "NeuroCont"
html_short_title = "NC"

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_book_theme'
html_static_path = ['_static']

html_js_files = [
    ("js/custom-icons.js", {"defer": "defer"}),
]

html_css_files =[
    "css/custom-style.css"
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
            "url": lab_link,
            "icon": "fa fa-university",
            "type": "fontawesome",
        },
    ],
}



latex_elements = {
    'preamble': r'''
\newcommand{\faMathWorks}{\begin{pgfpicture}\pgftransformyscale{-0.077ex}\pgftransformxscale{0.077ex}\pgfpathsvg{M5.765 21.661c-1.593-1.188-3.577-2.583-5.765-4.172l7.749-2.979 3.183 2.385c-2.385 2.781-3.973 3.776-5.167 4.771zM27.031 13.317c-0.599-1.588-0.995-3.181-1.593-4.771-0.593-1.792-1.187-3.38-2.183-4.771-0.4-0.593-1.192-1.989-2.187-1.989-0.199 0-0.396 0.197-0.599 0.197-0.595 0.204-1.391 1.391-1.589 2.188-0.593 0.995-1.792 2.583-2.583 3.577-0.199 0.396-0.6 0.797-0.797 0.996-0.593 0.395-1.193 0.995-1.984 1.391-0.204 0-0.401 0.197-0.599 0.197-0.595 0-0.996 0.396-1.391 0.593-0.595 0.6-1.193 1.391-1.787 1.991 0 0.197-0.204 0.395-0.401 0.599l2.984 2.181c2.188-2.583 4.771-5.167 6.557-10.135 0 0-0.593 5.369-5.364 11.131-2.985 3.38-5.371 5.171-5.767 5.567 0 0 0.792-0.197 1.589 0.199 1.593 0.593 2.385 2.781 2.984 4.369 0.396 1.193 0.989 2.188 1.391 3.38 1.589-0.396 2.584-0.995 3.579-1.989 0.989-0.989 1.984-2.183 2.979-3.177 1.792-2.187 3.975-4.968 6.756-3.577 0.4 0.197 0.995 0.599 1.192 0.796 0.599 0.396 0.995 0.792 1.593 1.391 0.991 0.792 1.391 1.391 2.183 1.787-1.984-3.973-3.375-7.948-4.968-12.125z}\pgfsetbaseline{-2.1ex}\pgfusepath{fill}\end{pgfpicture}}
    ''',
    'extrapackages': r'''
\usepackage{textcomp}
\usepackage[math-style=literal]{unicode-math}
\usepackage{pgfcore}
\usepgflibrary{svg.path}
    ''',
    'maketitle': r'''\newcommand\sphinxbackoftitlepage{\section*{Useful Links} \large
                                                       \href{'''+github_link+r'''}{\faGithub\ GitHub Link} 
                                                       \newline\href{'''+mathworks_link+r'''}{\faMathWorks\ MathWorks® File Exchange Link}
                                                       \newline\href{'''+lab_link+r'''}{\faUniversity\ Laboratory Link}
                                                       \newline\href{'''+doc_link+r'''}{\faLink\ Online Documentation Link} }\sphinxmaketitle'''
}


rst_prolog = """
.. role:: latex(raw)
    :format: latex

.. role:: html(raw)
    :format: html

.. |matlab| replace:: MATLAB®
.. |simulink| replace:: Simulink®
.. |matlab_simulink| replace:: MATLAB® and Simulink®
.. |mathworks| replace:: MathWorks®
.. |github| replace:: GitHub
.. |mathworks-file-exchange| replace:: MathWorks® File Exchange
.. |fa-github-html| raw:: html

    <i class="fa-brands fa-github"></i>
    
.. |fa-github-latex| raw:: latex

    \\faGithub

.. |fa-github| replace:: |fa-github-html|\\ |fa-github-latex|
    
.. |fa-mathworks-html| raw:: html

    <i class="fa-custom fa-mathworks"></i>
    
.. |fa-mathworks-latex| raw:: latex

    \\faMathWorks
    
.. |fa-mathworks| replace:: |fa-mathworks-html|\\ |fa-mathworks-latex|

.. |github-link-html| raw:: html

    <a href="""+github_link+"""><i class="fa-brands fa-github"></i>GitHub</a>
    
.. |github-link-latex| raw:: latex

    \\href{"""+github_link+"""}{\\faGithub GitHub} 
    
.. |github-link| replace:: |github-link-html|\\ |github-link-latex|

.. |mathworks-file-exchange-link-html| raw:: html

    <a href="""+mathworks_link+"""><i class="fa-custom fa-mathworks"></i>MathWorks® File Exchange</a>

.. |mathworks-file-exchange-link-latex| raw:: latex

    \\href{"""+mathworks_link+"""}{\\faMathWorks MathWorks® File Exchange} 
    
.. |mathworks-file-exchange-link| replace:: |mathworks-file-exchange-link-html|\\ |mathworks-file-exchange-link-latex|

.. role:: matlab(code)
    :language: matlab
"""

matlab_short_links = False
