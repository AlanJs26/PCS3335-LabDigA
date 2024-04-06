
fn print_binary(number: u32) {
    println!("{:08b}", number);
}

use rand::prelude::*;

fn rand_number(rng: &mut ThreadRng, bits: u32) -> u32 {
   let mut max_number: u32 = 1;

   for i in 1..bits {
       max_number += u32::pow(2, i);
   }

   let x: f32 = rng.gen();

   // println!("Random: {}", x);
   if bits == 1 {
       return match x>0.5 {
           true => 1,
           false => 0,
       }
   }

   return (x*(max_number as f32)) as u32;
}

fn gen_output(prev_reset: bool, prev_tx_go : bool, reset : bool, tx_go : bool, input : u32) -> String {

    if reset {
        unimplemented!();
    }
    String::from("alan")
}

fn main() {
    let mut rng = rand::thread_rng();


    // let mut prev_reset : bool = false;
    // let mut prev_tx_go : bool = false;

    for _i in 0..20 {
        // let reset : bool = rng.gen();
        // let tx_go : bool = rng.gen();
        let reset = rand_number(&mut rng, 1);
        let tx_go = rand_number(&mut rng, 1);
        //
        let sw = rand_number(&mut rng, 8);
        //
        // let output : &str = &gen_output(prev_reset, prev_tx_go, reset, tx_go, sw);
        //
        // println!("{}",output);
        //
        // prev_reset = reset;
        // prev_tx_go = tx_go;

        println!("{} {} {:08b}", reset, tx_go, sw);
            // print_binary(sw);
        
    }

    // println!("Random: {}", sw);
}
