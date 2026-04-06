project('year-progress', 'vala', 'c')

add_project_arguments('-DGETTEXT_PACKAGE="year-progress"', language: 'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gtk4')
]

executable('year-progress',
    'main.vala',
    dependencies: dependencies,
    install: true
)

install_data('data/year-progress.desktop',
    install_dir: get_option('datadir') / 'applications'
)

install_data('data/year-progress.svg',
    rename: 'year-progress.svg',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / 'scalable' / 'apps'
)


i18n = import('i18n')
subdir('po')