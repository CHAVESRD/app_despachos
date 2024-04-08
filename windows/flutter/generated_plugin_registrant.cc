//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auto_update/auto_update_plugin.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AutoUpdatePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AutoUpdatePlugin"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
}
