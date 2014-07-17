{ nixpkgs ? (import /home/fxr/nixos/nixpkgs {})
, haskellPackages ? nixpkgs.haskellPackages 
, cabal ? nixpkgs.haskellPackages.cabal
}:

cabal.mkDerivation (self : rec {
    pname = "jmacro-rpc-examples";
    version = "0.1.0.1";
    isExecutable = true;
    isLibrary = false;
    preConfigure = ''rm -rf dist'';
    src = ./.;

    buildDepends = with haskellPackages; [
        text
	mtl
	jmacro jmacroRpc jmacroRpcSnap
	snapServer
        snapCore
        xhtml
        blazeHtml
    ];
    buildTools = [ haskellPackages.cabalInstall_1_20_0_3 ];
})

