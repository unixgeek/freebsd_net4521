#include <fstream>
#include <regex.h>
#include <iostream>

#include "Config.h"

Config::Config(const char *file) {
    regex_t option_re; //(R"(\s*options\s+(\w+).*)");
    regex_t device_re; //(R"(\s*device\s+(\w+).*)");

    regcomp(&option_re, "^[[:space:]]{0,}options[[:space:]]{1,}([a-zA-Z]{1,}).*$", REG_EXTENDED);

    regcomp(&device_re, "[[:space:]]{0,}device[[:space:]]{1,}([a-zA-Z]{1,})[[:space:]]{0,}", REG_EXTENDED);

    regmatch_t groupArray[2];

    std::string line;

    std::fstream in;
    in.open(file,  std::ios_base::in);
	if (!in.is_open())
		perror("wtf");


    while (std::getline(in, line)) {
        int result = regexec(&option_re, line.c_str(), 2, groupArray, 0);
        if (result == 0) {
            std::string match(line, groupArray[1].rm_so, groupArray[1].rm_eo);
		std::cout << "[" << match << "]" << std::endl;
            options.insert(match);
        }
        else if (result != 1) {
            char msg[100];
            regerror(result, &option_re, msg, 100);
            std::cerr << msg << std::endl;
        }

        result = regexec(&device_re, line.c_str(), 2, groupArray, 0);
        if (result == 0) {
            std::string match(line, groupArray[1].rm_so, groupArray[1].rm_eo);
		std::cout << "[" << match << "]" << std::endl;
            devices.insert(match);
        }
        else if (result != 1) {
            char msg[100];
            regerror(result, &device_re, msg, 100);
            std::cerr << msg << std::endl;
        }

    }

if (in.bad())
	perror("bad");

    regfree(&option_re);
    regfree(&device_re);
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

std::set<std::string> Config::get_diff(const std::set<std::string> &a, const std::set<std::string> &b) {
    std::set<std::string> difference;

    std::set<std::string>::iterator  other_iterator = a.begin();
    while (other_iterator != a.end()) {
        std::string target = (*other_iterator);

        bool found = false;
        std::set<std::string>::iterator  this_iterator = b.begin();
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
