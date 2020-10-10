#include <string>
#include <iostream>
#include <set>
#include "Config.h"

void assert(const std::set<std::string>& set, std::string key);

int main(int argc, char *argv[]) {
    std::string file;

    if (argc == 2) {
        file = argv[1];
    } else {
        std::cout << "usage: " << argv[0] << " FILE" << std::endl;
        return 1;
    }

    if (file.empty()) {
        std::cerr << "No FILE specified" << std::endl;
        return 1;
    }

    Config a(file.c_str());

    std::cout << std::endl << "=== Test Results ===" << std::endl;

//    std::set<std::string> devices  = a.get_devices();
//    assert(devices, "apic");
//    assert(devices, "gzip");
//    assert(devices, "xboxfb");
//    assert(devices, "nvram");
//    assert(devices, "apm_saver");
//    assert(devices, "isa");

    std::set<std::string> options  = a.get_options();
    assert(options, "MPTABLE_FORCE_HTT");
    assert(options, "CPU_BLUELIGHTNING_3X");
    assert(options, "CPU_ELAN_XTAL=32768000");
    assert(options, "XBOX");
    assert(options, "DEVICE_POLLING");
    assert(options, "BPF_JITTER");
    assert(options, "MAX_MEM=(128*1024)");
    assert(options, "TIMER_FREQ=((14318182+6)/12)");
    assert(options, "_KPOSIX_PRIORITY_SCHEDULING");

}

void assert(const std::set<std::string>& set, std::string key) {
    if (set.count(key) != 1) {
        std::cout << "FAIL: " << key << std::endl;
    }
    else {
        std::cout << "PASS: " << key << std::endl;
    }
}
