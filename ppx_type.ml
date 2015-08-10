open Asttypes
open Parsetree

(*
let do_magic vb = ()

let structure_items_of_item mapper (x : structure_item) : structure_item list =
  let x = mapper.Ast_mapper.structure_item mapper x in
  let add_to_value_binding vb =
    match Ast_convenience.find_attr "typeme" vb.pvb_attributes with
    | None -> [vb]
    | Some (PStr []) ->
        do_magic vb
    | Some (PPat _) | Some (PTyp _) | Some (PStr (_::_)) ->
      error "expected empty payload"
  in
  match x.pstr_desc with
  | Pstr_value (rf, vbs) ->
      let vs = List.map add_to_value_binding vbs
      let x  = {x with pstr_desc = (Pstr_value (rf, vs))} in
      [x]
  | _ -> [x]
  *)

  (*
let structure_mapper mapper structure =
  List.map structure ~f:(structure_items_of_item mapper)
  |> List.concat

let mapper = Ast_mapper.{default_mapper with
  structure = structure_mapper;
}
*)

let structure_mapper (typer,outputfile) mapper (structure : structure) =
  let copied = List.map (fun si -> mapper.Ast_mapper.structure_item mapper si) structure in
  let typed = typer copied in
  let _ = 
    let oc = open_out_bin outputfile in
    let pf = Format.formatter_of_out_channel oc in
    Printtyped.implementation_with_coercion pf typed;
    close_out oc;
  in
  copied

let mapper filename =
  let outputprefix = Filename.chop_extension filename in
  let modulename = Compenv.module_of_filename Format.err_formatter filename outputprefix in
  Env.set_unit_name modulename;
  let env = Compmisc.initial_env() in
  let type_structure =
    Typemod.type_implementation filename outputprefix modulename env
  in
  let typed_filename = modulename ^ ".mltyped" in
  Ast_mapper.{ default_mapper with
    structure = structure_mapper (type_structure, typed_filename);
  }


let () =
  Ast_mapper.run_main(fun _argv ->
    let filename = !Location.input_name in
    (*let _ = Printf.eprintf "This is the location name %s\n%!" filename in *)
    mapper filename)
