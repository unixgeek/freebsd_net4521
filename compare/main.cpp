#include <string>
#include <iostream>
#include <set>
#include "Config.h"

void print_set(const std::set<std::string>& set);

int main(int argc, char *argv[]) {
    std::string filea;
    std::string fileb;

    if (argc == 3) {
        filea = argv[1];
        fileb = argv[2];
    } else {
        std::cout << "usage: " << argv[0] << " FILEA FILEB" << std::endl;
        return 1;
    }

    if (filea.empty()) {
        std::cerr << "No FILEA specified" << std::endl;
        return 1;
    }

    if (fileb.empty()) {
        std::cerr << "No FILEB specified" << std::endl;
        return 1;
    }

    Config a(filea.c_str());
    Config b(fileb.c_str());

    std::set<std::string> options_in_b_only = a.options_difference(b);
    std::set<std::string> devices_in_b_only = a.devices_difference(b);

    std::set<std::string> options_in_a_only = b.options_difference(a);
    std::set<std::string> devices_in_a_only = b.devices_difference(a);

    std::cout << " ** in a only ** " << std::endl;
    print_set(options_in_a_only);
    print_set(devices_in_a_only);

    std::cout << " ** in b only ** " << std::endl;
    print_set(options_in_b_only);
    print_set(devices_in_b_only);
}

void print_set(const std::set<std::string>& set) {
    std::set<std::string>::iterator iterator = set.begin();
    while (iterator != set.end()) {
        std::cout << (*iterator) << std::endl;
        iterator++;
    }
}
