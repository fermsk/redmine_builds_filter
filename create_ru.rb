require 'yaml'

translations = {
  'ru' => {
    'field_build' => "Сборка",
    'field_build_closed' => "Закрыто в сборке",
    'permission_manage_builds' => "Управление сборками",
    'project_module_builds' => "Сборки"
  }
}

File.open('config/locales/ru.yml', 'w') do |file|
  file.write(translations.to_yaml)
end

puts "Created or updated ru.yml file with Russian translations"