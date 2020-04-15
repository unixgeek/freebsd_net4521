#include <set>
#include <string>

#ifndef COMPARE_CONFIG_H
#define COMPARE_CONFIG_H


class Config {
private:
    std::set<std::string> options;
    std::set<std::string> devices;
    static std::set<std::string> get_diff(const std::set<std::string>& a, const std::set<std::string>& b);
public:
    explicit Config(const char *);

    std::set<std::string> options_difference(Config config);

    std::set<std::string> devices_difference(Config config);

    std::set<std::string> get_options();
    std::set<std::string> get_devices();
};


#endif //COMPARE_CONFIG_H
