{******************************************************************************}
{                                                                              }
{  Neon: Serialization Library for Delphi                                      }
{  Copyright (c) 2018-2019 Paolo Rossi                                         }
{  https://github.com/paolo-rossi/neon-library                                 }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit Neon.Tests.Entities;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

{$SCOPEDENUMS ON}

type
  TContactType = (Phone, Email, Skype);

  TSimpleRecord = record
    Name: string;
    BirthDate: TDateTime;
    Age: Integer;
  end;

  TContact = class
  private
    FContactType: TContactType;
    FNumber: string;
  public
    property ContactType: TContactType read FContactType write FContactType;
    property Number: string read FNumber write FNumber;
  end;

  TAddress = class
  private
    FCity: string;
    FCountry: string;
    FPrimary: Boolean;
    FStreet: string;
  public
    property Street: string read FStreet write FStreet;
    property City: string read FCity write FCity;
    property Country: string read FCountry write FCountry;
    property Primary: Boolean read FPrimary write FPrimary;
  end;

  TPerson = class
  private
    FName: string;
    FAge: Integer;
    FAddresses: TArray<TAddress>;
    FContacts: TObjectList<TContact>;
  public
    constructor Create(const AName: string; AAge: Integer);
    destructor Destroy; override;

    function AddAddress(const AStreet, ACity, ACountry: string; APrimary: Boolean): TAddress;
    function AddContact(AType: TContactType; const ANumber: string): TContact;

    property Name: string read FName write FName;
    property Age: Integer read FAge write FAge;
    property Addresses: TArray<TAddress> read FAddresses write FAddresses;
    property Contacts: TObjectList<TContact> read FContacts write FContacts;
  end;

implementation

{ TPerson }

function TPerson.AddAddress(const AStreet, ACity, ACountry: string; APrimary: Boolean): TAddress;
begin
  Result := TAddress.Create;
  Result.Street := AStreet;
  Result.City := ACity;
  Result.Country := ACountry;
  Result.Primary := APrimary;
  FAddresses := FAddresses + [Result];
end;

function TPerson.AddContact(AType: TContactType; const ANumber: string): TContact;
begin
  Result := TContact.Create;
  Result.ContactType := AType;
  Result.Number := ANumber;
  FContacts.Add(Result);
end;

constructor TPerson.Create(const AName: string; AAge: Integer);
begin
  FContacts := TObjectlist<TContact>.Create(True);

  FName := AName;
  FAge := AAge;
end;

destructor TPerson.Destroy;
var
  LIndex: Integer;
begin
  for LIndex := Length(FAddresses) - 1 downto 0 do
    FAddresses[LIndex].Free;

  FContacts.Free;
  inherited;
end;

end.
