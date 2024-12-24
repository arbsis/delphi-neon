unit Neon.Core.Nullables;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.Generics.Defaults, System.Rtti,
  System.TypInfo, System.JSON;

type
  ENullableException = class(Exception);

  {$RTTI EXPLICIT FIELDS([vcPrivate]) METHODS([vcPrivate])}
  Nullable<T> = record
  private
    FValue: T;
    FHasValue: Boolean;
    procedure Clear;
    function GetValueType: PTypeInfo;
    function GetValue: T;
    procedure SetValue(const AValue: T);
    function GetHasValue: Boolean;
    class function VarIsNullOrEmpty(const Value: Variant): Boolean; static;
  public
    constructor Create(const Value: T); overload;
    constructor Create(const Value: Variant); overload;
    function Equals(const Value: Nullable<T>): Boolean; overload;
    function Equals(const Value: T): Boolean; overload;
    function GetValueOrDefault: T; overload;
    function GetValueOrDefault(const Default: T): T; overload;
    function ToString: String;
    function ToVariant: Variant;

    property HasValue: Boolean read GetHasValue;
    function IsNull: Boolean;

    property Value: T read GetValue;

    class operator Implicit(const Value: Nullable<T>): T;
    class operator Implicit(const Value: Nullable<T>): Variant;
    class operator Implicit(const Value: Pointer): Nullable<T>;
    class operator Implicit(const Value: T): Nullable<T>;
    class operator Implicit(const Value: Variant): Nullable<T>;
    class operator Implicit(const Value: TValue): Nullable<T>;
    class operator Equal(const Left, Right: Nullable<T>): Boolean; overload;
    class operator Equal(const Left: Nullable<T>; Right: T): Boolean; overload;
    class operator Equal(const Left: T; Right: Nullable<T>): Boolean; overload;
    class operator NotEqual(const Left, Right: Nullable<T>): Boolean; overload;
    class operator NotEqual(const Left: Nullable<T>; Right: T): Boolean; overload;
    class operator NotEqual(const Left: T; Right: Nullable<T>): Boolean; overload;
    class operator GreaterThan(const Left: Nullable<T>; Right: T): Boolean; overload;
    class operator LessThan(const Left: Nullable<T>; Right: T): Boolean; overload;

  end;

  NullString = Nullable<string>;
  NullBoolean = Nullable<Boolean>;
  NullInteger = Nullable<Integer>;
  NullInt64 = Nullable<Int64>;
  NullDouble = Nullable<Double>;
  NullCurrency = Nullable<Currency>;
  NullDate = Nullable<TDate>;
  NullTime = Nullable<TTime>;
  NullDateTime = Nullable<TDateTime>;

implementation

const
  CHasValueFlag = '@';

{ Nullable<T> }

constructor Nullable<T>.Create(const Value: T);
begin
  FValue := Value;
  FHasValue := True;
end;

constructor Nullable<T>.Create(const Value: Variant);
begin
  if not VarIsNull(Value) and not VarIsEmpty(Value) then
    Create(TValue.FromVariant(Value).AsType<T>)
  else
    Clear;
end;

procedure Nullable<T>.Clear;
begin
  FValue := Default(T);
  FHasValue := False;
end;

class operator Nullable<T>.Equal(const Left: Nullable<T>; Right: T): Boolean;
begin
  Result := Left.Equals(Right);
end;

class operator Nullable<T>.Equal(const Left: T; Right: Nullable<T>): Boolean;
begin
  Result := Right.Equals(Left);
end;

function Nullable<T>.Equals(const Value: T): Boolean;
begin
  Result := HasValue and TEqualityComparer<T>.Default.Equals(Self.Value, Value)
end;

function Nullable<T>.Equals(const Value: Nullable<T>): Boolean;
begin
  if HasValue and Value.HasValue then
    Result := TEqualityComparer<T>.Default.Equals(Self.Value, Value.Value)
  else
    Result := HasValue = Value.HasValue;
end;

function Nullable<T>.GetHasValue: Boolean;
begin
  Result := FHasValue;
end;

function Nullable<T>.GetValueType: PTypeInfo;
begin
  Result := TypeInfo(T);
end;

class operator Nullable<T>.GreaterThan(const Left: Nullable<T>; Right: T): Boolean;
begin
  Result := Left.HasValue and (TComparer<T>.Default.Compare(Left.Value, Right) > 0);
end;

function Nullable<T>.GetValue: T;
begin
  if not HasValue then
    raise ENullableException.Create('Nullable type has no value');
  Result := FValue;
end;

function Nullable<T>.GetValueOrDefault(const Default: T): T;
begin
  if HasValue then
    Result := FValue
  else
    Result := Default;
end;

function Nullable<T>.GetValueOrDefault: T;
begin
  Result := GetValueOrDefault(Default(T));
end;

class operator Nullable<T>.Implicit(const Value: Nullable<T>): T;
begin
  Result := Value.Value;
end;

class operator Nullable<T>.Implicit(const Value: Nullable<T>): Variant;
begin
  if Value.HasValue then
    Result := TValue.From<T>(Value.Value).AsVariant
  else
    Result := Null;
end;

class operator Nullable<T>.Implicit(const Value: Pointer): Nullable<T>;
begin
  if Value = nil then
    Result.Clear
  else
    Result := Nullable<T>.Create(T(Value^));
end;

class operator Nullable<T>.Implicit(const Value: T): Nullable<T>;
begin
  Result := Nullable<T>.Create(Value);
end;

class operator Nullable<T>.Implicit(const Value: Variant): Nullable<T>;
begin
  Result := Nullable<T>.Create(Value);
end;

function Nullable<T>.IsNull: Boolean;
begin
  Result := not FHasValue;
end;

class operator Nullable<T>.LessThan(const Left: Nullable<T>; Right: T): Boolean;
begin
  Result := Left.HasValue and (TComparer<T>.Default.Compare(Left.Value, Right) < 0);
end;

class operator Nullable<T>.NotEqual(const Left: Nullable<T>; Right: T): Boolean;
begin
  Result := not Left.Equals(Right);
end;

class operator Nullable<T>.NotEqual(const Left: T; Right: Nullable<T>): Boolean;
begin
  Result := not Right.Equals(Left);
end;

class operator Nullable<T>.Equal(const Left, Right: Nullable<T>): Boolean;
begin
  Result := Left.Equals(Right);
end;

class operator Nullable<T>.NotEqual(const Left, Right: Nullable<T>): Boolean;
begin
  Result := not Left.Equals(Right);
end;

procedure Nullable<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class operator Nullable<T>.Implicit(const Value: TValue): Nullable<T>;
begin
  Result := Nullable<T>.Create(Value.AsType<T>);
end;

function Nullable<T>.ToString: String;
var
  LValue: TValue;
begin
  if HasValue then
  begin
    LValue := TValue.From<T>(FValue);
    Result := LValue.ToString;
  end
  else
    Result := 'Null';
end;

function Nullable<T>.ToVariant: Variant;
var
  LValue: TValue;
begin
  if HasValue then
  begin
    LValue := TValue.From<T>(FValue);
    if LValue.IsType<Boolean> then
      Result := LValue.AsBoolean
    else
      Result := LValue.AsVariant;
  end
  else
    Result := Null;
end;


class function Nullable<T>.VarIsNullOrEmpty(const Value: Variant): Boolean;
begin
  Result := VarIsNull(Value) or VarIsEmpty(Value);
end;

end.
