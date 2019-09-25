mod ext_process;

fn main() {
    let directory = ext_process::get_appimage_directory();
    println!("The directory is: {}", directory);
    ext_process::create_new_environment();
}
