#
# JupyterZMQ: UUID function

#X tie in a UUID library or write the functionality in GAP
#X This only generates a random UUID (type 4)

#! @Description
#!   Generate a random UUID
DeclareGlobalFunction("RandomUUID");
DeclareGlobalFunction("StringUUID");
DeclareGlobalFunction("HexStringUUID");

BindGlobal( "UUIDFamily", NewFamily("UUIDFamily") );
DeclareCategory( "IsUUID", IsComponentObjectRep );
DeclareRepresentation( "IsUUIDBlistRep", IsUUID, ["bits"]);
BindGlobal( "UUIDType", NewType(UUIDFamily, IsUUIDBlistRep ));

DeclareGlobalFunction( "NewUUID" );
