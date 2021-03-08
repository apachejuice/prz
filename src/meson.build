prz_sources = [
  'main.vala',
  'bytescanner.vala',
  'formaterror.vala',
  'error.vala',
  'config.vapi',
  'pool.vala',
  'util.vala',
  'byteparser.vala',
  'code.vala',
  'type.vala',
  'constant.vala',
]

prz_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gee-0.8'),
]

config_h = configuration_data()
config_h.set('platform', build_machine.system())

configure_file(
  input: 'config.h.in',
  output: 'config.h',
  configuration: config_h,
)

valac_args = ['--target-glib=2.50', '--pkg', 'linux'] # dependency('linux') won't work?
debugmode = get_option('debugmode')
message('Debug = @0@'.format(debugmode))
if debugmode
  valac_args += ['-g', '-D', 'DEBUG']
endif

executable(
  'prz',
  prz_sources,
  vala_args: valac_args,
  dependencies: prz_deps,
  vala_vapi: 'prz-1.0.vapi',
  install: true,
)
