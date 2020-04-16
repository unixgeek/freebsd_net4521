#include <fstream>
#include <regex>

#include "Config.h"

Config::Config(const char *file) {
    std::regex option_re(R"(\s*options\s+(\w+).*)");
    std::regex device_re(R"(\s*device\s+(\w+).*)");
    std::smatch match;

    std::string line;
    std::fstream in;
    in.open(file);
    while (std::getline(in, line)) {
        if (std::regex_match(line, match, option_re)) {
            std::string x = match.str(1);
            options.insert(x);
        }
        if (std::regex_match(line, match, device_re)) {
            std::string x = match.str(1);
            devices.insert(x);
        }
    }
    in.close();
}

std::set<std::string> Config::options_difference(Config config) {
    return get_diff(config.get_options(), get_options());
}

std::set<std::string> Config::devices_difference(Config config) {
    return get_diff(config.get_devices(), get_devices());
}

std::set<std::string> Config::get_options() {
    return options;
}

std::set<std::string> Config::get_devices() {
    return devices;
}

std::set<std::string> Config::get_diff(const std::set<std::string>& a, const std::set<std::string>& b) {
    std::set<std::string> difference;

    auto other_iterator = a.begin();
    while (other_iterator != a.end()) {
        std::string target = (*other_iterator);

        bool found = false;
        auto this_iterator = b.begin();
        while (this_iterator != b.end()) {
            std::string x = (*this_iterator);

            if (target == x) {
                found = true;
                break;
            }
            this_iterator++;
        }

        if (!found) {
            difference.insert(target);
        }
        other_iterator++;
    }
    return difference;
}
