prvm_sources = [
  'bytescanner.vala',
  'formaterror.vala',
  'error.vala',
  'config.vapi',
  'pool.vala',
  'util.vala',
  'byteparser.vala',
  'code.vala',
  'type.vala',
  'function.vala',
  'vm.vala',
  'stack.vala',
  'vmerror.vala',
]

prvm_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gee-0.8'),
]

config_h = configuration_data()
config_h.set('platform', build_machine.system())
config_h.set('name', meson.project_name())
config_h.set('ver', meson.project_version())

configure_file(
  input: 'config.h.in',
  output: 'config.h',
  configuration: config_h,
)

valac_args = ['--target-glib=2.50', '--pkg', 'linux'] # dependency('linux') won't work?

shared_library(
  'prvm',
  prvm_sources,
  vala_args: valac_args,
  dependencies: prvm_deps,
  vala_vapi: 'prvm-1.0.vapi',
  install: true,
)

# We sadly can't link with the library above
# because vala-language-server won't pick it up :(
executable(
  'prvm',
  prvm_sources + ['main.vala'],
  vala_args: valac_args,
  dependencies: prvm_deps,
  install: true,
)