use std::{
    collections::HashMap,
    env,
    ffi::CString,
};

// Get the location of the executable. It will be in usr/bin somewhere
// Use at as basis for the ENV variable generation
// Remove bogus entities from the ENV list for a new process
// Start the new process with the new environment

pub fn get_appimage_directory() -> String {
    let current_exe = env::current_exe().expect("Failed to get path to current executable");
    let parent_path = current_exe.parent().and_then( |path| {
        path.parent()
    }).and_then( |path| {
        path.parent()
    }).expect("Failed to get the location of the AppImage");
    let mut path = String::new();
    path.push_str(parent_path.to_str().unwrap());
    return path;
}

pub fn create_new_environment() -> Vec<CString> {
    let mut environment = Environment {
        env: copy_environment(),
        root_dir: get_appimage_directory()
    };
    patch_variables(&mut environment);
    convert_environment_to_cstrings(&environment)
}

struct Environment {
    env: HashMap<String, String>,
    root_dir: String,
}

const OS_ENV_PREFIX: &str = "OS_ENV_";

fn copy_environment() -> HashMap<String, String> {
    let mut environment = HashMap::new();
    for(key, value) in env::vars() {
        let os_key = format!("{}{}", OS_ENV_PREFIX, key);
        environment.insert(os_key, String::from(&value));
        environment.insert(key, value);
    }
    environment
}

fn patch_variables(environment: &mut Environment) {
    patch_variable("PATH", vec!["/usr/bin"], environment);
    patch_variable("LD_LIBRARY_PATH", vec!["/usr/lib", "/usr/lib/x86_64-linux-gnu",
                                           "/usr/lib64"], environment);
    patch_variable("PYTHONPATH", vec!["/usr/share/pyshared"], environment);
    patch_variable("XDG_DATA_DIRS", vec!["/usr/share"], environment);
    patch_variable("PERLLIB", vec!["/usr/share/perl5", "/usr/lib/perl5"],
                   environment);
    // http://askubuntu.com/questions/251712/how-can-i-install-a-gsettings-schema-without-root-privileges
    patch_variable("GSETTINGS_SCHEMA_DIR", vec!["/usr/share/glib-2.0/schemas/"],
                   environment);
    patch_variable("QT_PLUGIN_PATH", vec![], environment);
}

fn patch_variable(variable: &str, paths: Vec<&str>, environment: &mut Environment) {
    let mut printed_paths: Vec<String> = paths.into_iter().map(|path| {
        format!("{root_dir}{path}", root_dir = environment.root_dir, path = path)
    }).collect();
    let cur_value = environment.env.get(variable);
    if cur_value.is_some() {
        printed_paths.push(cur_value.unwrap().to_string());
    }
    environment.env.insert(variable.to_string(), printed_paths.join(":"));
}

fn convert_environment_to_cstrings(environment: &Environment) -> Vec<CString> {
    let mut result = Vec::new();
    for (key, value) in &environment.env {
        let new_env = format!("{}={}", key, value);
        println!("{}", new_env);
        result.push(CString::new(new_env).unwrap());
    }
    result
}
