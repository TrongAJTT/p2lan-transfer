#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

// Add includes for Windows WiFi API
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <wlanapi.h>
#include <iphlpapi.h>
#include <netlistmgr.h>
#include <comdef.h>

#pragma comment(lib, "wlanapi.lib")
#pragma comment(lib, "iphlpapi.lib")
#pragma comment(lib, "ole32.lib")

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here is arbitrary since we maintain a 1:1 ratio between Pixels
  // and DIPs.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  
  // Register method channel for network security
  SetupMethodChannel();
  
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // callback is called.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

void FlutterWindow::SetupMethodChannel() {
  const std::string channel_name = "dev.trongajtt.p2lan/network_security";
  
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), channel_name,
      &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler([this](const flutter::MethodCall<flutter::EncodableValue>& call,
                                      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    this->HandleMethodCall(call, std::move(result));
  });

  method_channel_ = std::move(channel);
}

void FlutterWindow::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  
  const std::string& method = method_call.method_name();

  if (method == "checkWifiSecurity") {
    auto wifi_info = CheckWifiSecurity();
    result->Success(wifi_info);
  } else if (method == "getNetworkInfo") {
    auto network_info = GetNetworkInfo();
    result->Success(network_info);
  } else if (method == "requestPermissions") {
    // Windows doesn't require special permissions for WiFi info
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

flutter::EncodableValue FlutterWindow::CheckWifiSecurity() {
  flutter::EncodableMap result;
  
  try {
    result[flutter::EncodableValue("hasPermission")] = flutter::EncodableValue(true);
    
    // Initialize WLAN API
    HANDLE hClient = NULL;
    DWORD dwMaxClient = 2;
    DWORD dwCurVersion = 0;
    DWORD dwResult = 0;
    
    dwResult = WlanOpenHandle(dwMaxClient, NULL, &dwCurVersion, &hClient);
    if (dwResult != ERROR_SUCCESS) {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isSecure")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("securityType")] = flutter::EncodableValue("NO_WLAN_SERVICE");
      return result;
    }

    // Enumerate wireless interfaces
    PWLAN_INTERFACE_INFO_LIST pIfList = NULL;
    dwResult = WlanEnumInterfaces(hClient, NULL, &pIfList);
    
    if (dwResult != ERROR_SUCCESS || pIfList == NULL || pIfList->dwNumberOfItems == 0) {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isSecure")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("securityType")] = flutter::EncodableValue("NO_WIFI_ADAPTER");
      
      if (pIfList != NULL) {
        WlanFreeMemory(pIfList);
      }
      WlanCloseHandle(hClient, NULL);
      return result;
    }

    // Check the first WiFi interface
    PWLAN_INTERFACE_INFO pIfInfo = &pIfList->InterfaceInfo[0];
      
      if (pIfInfo->isState == wlan_interface_state_connected) {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(true);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(true);
        
      // Get current connection attributes
        PWLAN_CONNECTION_ATTRIBUTES pConnectInfo = NULL;
        DWORD connectInfoSize = sizeof(WLAN_CONNECTION_ATTRIBUTES);
        WLAN_OPCODE_VALUE_TYPE opCode = wlan_opcode_value_type_invalid;
        
        dwResult = WlanQueryInterface(hClient, &pIfInfo->InterfaceGuid,
                                    wlan_intf_opcode_current_connection,
                                   NULL, &connectInfoSize, (PVOID*)&pConnectInfo, &opCode);
        
        if (dwResult == ERROR_SUCCESS && pConnectInfo != NULL) {
          // Get SSID
          std::string ssid((char*)pConnectInfo->wlanAssociationAttributes.dot11Ssid.ucSSID,
                          pConnectInfo->wlanAssociationAttributes.dot11Ssid.uSSIDLength);
          result[flutter::EncodableValue("ssid")] = flutter::EncodableValue(ssid);
          
        // Get signal quality
        result[flutter::EncodableValue("signalLevel")] = flutter::EncodableValue(static_cast<int>(pConnectInfo->wlanAssociationAttributes.wlanSignalQuality));
        
        // Determine security type
        DOT11_AUTH_ALGORITHM authAlg = pConnectInfo->wlanSecurityAttributes.dot11AuthAlgorithm;
        DOT11_CIPHER_ALGORITHM cipherAlg = pConnectInfo->wlanSecurityAttributes.dot11CipherAlgorithm;
        
        std::string securityType;
        bool isSecure = false;
        
        switch (authAlg) {
          case DOT11_AUTH_ALGO_80211_OPEN:
            securityType = (cipherAlg == DOT11_CIPHER_ALGO_NONE) ? "OPEN" : "WEP";
            isSecure = (cipherAlg != DOT11_CIPHER_ALGO_NONE);
            break;
          case DOT11_AUTH_ALGO_WPA:
            securityType = "WPA";
            isSecure = true;
            break;
          case DOT11_AUTH_ALGO_WPA_PSK:
            securityType = "WPA_PSK";
            isSecure = true;
            break;
          case DOT11_AUTH_ALGO_RSNA:
            securityType = "WPA2";
            isSecure = true;
            break;
          case DOT11_AUTH_ALGO_RSNA_PSK:
            securityType = "WPA2_PSK";
            isSecure = true;
            break;
          default:
            securityType = "UNKNOWN";
            isSecure = true; // Assume secure for unknown types
            break;
        }
        
        result[flutter::EncodableValue("securityType")] = flutter::EncodableValue(securityType);
        result[flutter::EncodableValue("isSecure")] = flutter::EncodableValue(isSecure);
          
        WlanFreeMemory(pConnectInfo);
      } else {
        result[flutter::EncodableValue("isSecure")] = flutter::EncodableValue(false);
        result[flutter::EncodableValue("securityType")] = flutter::EncodableValue("UNKNOWN");
        }
    } else {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isSecure")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("securityType")] = flutter::EncodableValue("NOT_CONNECTED");
    }
    
    // Clean up
    if (pIfList != NULL) {
    WlanFreeMemory(pIfList);
    }
    WlanCloseHandle(hClient, NULL);
    
  } catch (...) {
    result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
    result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
    result[flutter::EncodableValue("isSecure")] = flutter::EncodableValue(false);
    result[flutter::EncodableValue("securityType")] = flutter::EncodableValue("ERROR");
  }
  
  return result;
}

flutter::EncodableValue FlutterWindow::GetNetworkInfo() {
  flutter::EncodableMap result;
  
  try {
    // Initialize COM
    CoInitialize(NULL);
    
    // Create NetworkListManager instance
    INetworkListManager* pNetworkListManager = NULL;
    HRESULT hr = CoCreateInstance(CLSID_NetworkListManager, NULL, CLSCTX_ALL,
                                 IID_INetworkListManager, (LPVOID*)&pNetworkListManager);
    
    if (SUCCEEDED(hr)) {
      NLM_CONNECTIVITY connectivity;
      hr = pNetworkListManager->GetConnectivity(&connectivity);
      
      if (SUCCEEDED(hr)) {
        bool hasInternet = (connectivity & NLM_CONNECTIVITY_IPV4_INTERNET) || 
                          (connectivity & NLM_CONNECTIVITY_IPV6_INTERNET);
        bool isConnected = (connectivity & NLM_CONNECTIVITY_IPV4_LOCALNETWORK) ||
                          (connectivity & NLM_CONNECTIVITY_IPV6_LOCALNETWORK) ||
                          hasInternet;
        
        result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(isConnected);
        result[flutter::EncodableValue("hasInternet")] = flutter::EncodableValue(hasInternet);
      
        // Determine connection type using GetAdaptersInfo
      bool isWiFi = false;
      bool isMobile = false;
      bool isEthernet = false;
      
        PIP_ADAPTER_INFO pAdapterInfo = (IP_ADAPTER_INFO*)malloc(sizeof(IP_ADAPTER_INFO));
      ULONG ulOutBufLen = sizeof(IP_ADAPTER_INFO);

      if (GetAdaptersInfo(pAdapterInfo, &ulOutBufLen) == ERROR_BUFFER_OVERFLOW) {
          free(pAdapterInfo);
          pAdapterInfo = (IP_ADAPTER_INFO*)malloc(ulOutBufLen);
      }
      
      if (pAdapterInfo && GetAdaptersInfo(pAdapterInfo, &ulOutBufLen) == NO_ERROR) {
          PIP_ADAPTER_INFO pAdapter = pAdapterInfo;
          while (pAdapter) {
              if (pAdapter->Type == MIB_IF_TYPE_ETHERNET && strcmp(pAdapter->IpAddressList.IpAddress.String, "0.0.0.0") != 0) {
                  isEthernet = true;
                  result[flutter::EncodableValue("ipAddress")] = flutter::EncodableValue(std::string(pAdapter->IpAddressList.IpAddress.String));
                  result[flutter::EncodableValue("gatewayAddress")] = flutter::EncodableValue(std::string(pAdapter->GatewayList.IpAddress.String));
                  break; // Found the primary ethernet adapter
              } else if (pAdapter->Type == IF_TYPE_IEEE80211 && strcmp(pAdapter->IpAddressList.IpAddress.String, "0.0.0.0") != 0) {
                  isWiFi = true;
                  result[flutter::EncodableValue("ipAddress")] = flutter::EncodableValue(std::string(pAdapter->IpAddressList.IpAddress.String));
                  result[flutter::EncodableValue("gatewayAddress")] = flutter::EncodableValue(std::string(pAdapter->GatewayList.IpAddress.String));
                  break; // Found the primary wifi adapter
              }
              pAdapter = pAdapter->Next;
          }
      }
      
      if (pAdapterInfo) {
          free(pAdapterInfo);
      }
      
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(isWiFi);
      result[flutter::EncodableValue("isMobile")] = flutter::EncodableValue(isMobile);
      result[flutter::EncodableValue("isEthernet")] = flutter::EncodableValue(isEthernet);
      
      pNetworkListManager->Release();
    } else {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isMobile")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isEthernet")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("hasInternet")] = flutter::EncodableValue(false);
      }
    } else {
      result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isMobile")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("isEthernet")] = flutter::EncodableValue(false);
      result[flutter::EncodableValue("hasInternet")] = flutter::EncodableValue(false);
    }
    
    CoUninitialize();
  } catch (...) {
    result[flutter::EncodableValue("isConnected")] = flutter::EncodableValue(false);
    result[flutter::EncodableValue("isWiFi")] = flutter::EncodableValue(false);
    result[flutter::EncodableValue("isMobile")] = flutter::EncodableValue(false);
    result[flutter::EncodableValue("isEthernet")] = flutter::EncodableValue(false);
    result[flutter::EncodableValue("hasInternet")] = flutter::EncodableValue(false);
  }
  
  return result;
}
