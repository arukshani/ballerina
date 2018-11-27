// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;

type Person record {
    string name = "";
    int age = 0;
    Person? parent = ();
    json info?;
    map<anydata>? address?;
    int[]? marks?;
    anydata a = ();
    float score = 0.0;
    boolean alive = false;
    Person[]? children?;
    !...
};

type Person2 record {
    string name = "";
    int age = 0;
    !...
};

type Person3 record {
    string name = "";
    int age = 0;
    string gender = "";
    !...
};

type Person4 record {
    string name = "";
    Person4? parent = ();
    map? address?;
    !...
};

type Student record {
    string name = "";
    int age = 0;
    !...
};

function testStructToMap () returns (map | error) {
    Person p = {name:"Child",
                   age:25,
                   parent:{name:"Parent", age:50},
                   address:{"city":"Colombo", "country":"SriLanka"},
                   info:{status:"single"},
                   marks:[67, 38, 91]
               };
    map<anydata> m =  check map<anydata>.create(p);
    return m;
}


function testMapToStruct () returns Person|error {
    int[] marks = [87, 94, 72];
    Person parent = {
                        name:"Parent",
                        age:50,
                        parent:null,
                        address:null,
                        info:null,
                        marks:null,
                        a:null,
                        score:4.57,
                        alive:false,
                        children:()
                    };

    json info = {status:"single"};
    map<string> addr = {"city":"Colombo", "country":"SriLanka"};
    map m = {name:"Child",
                age:25,
                parent:parent,
                address:addr,
                info:info,
                marks:marks,
                a:"any value",
                score:5.67,
                alive:true
            };
    Person p = check Person.create(m);
    return p;
}

function testNestedMapToNestedStruct() returns Person|error {
    int[] marks = [87, 94, 72];
    map parent = {
        name:"Parent",
        age:50,
        parent:null,
        address:null,
        info:null,
        marks:null,
        a:null,
        score:4.57,
        alive:false
    };

    json info = {status:"single"};
    map<string> addr = {"city":"Colombo", "country":"SriLanka"};
    map m = {name:"Child",
        age:25,
        parent:parent,
        address:addr,
        info:info,
        marks:marks,
        a:"any value",
        score:5.67,
        alive:true
    };
    Person p = check Person.create(m);
    return p;
}

function testStructToJson () returns json|error {
    Person p = {name:"Child",
                   age:25,
                   parent:{name:"Parent", age:50},
                   address:{"city":"Colombo", "country":"SriLanka"},
                   info:{status:"single"},
                   marks:[87, 94, 72],
                   a:"any value",
                   score:5.67,
                   alive:true,
                   children:()
               };

    json j = check json.create(p);
    return j;
}


//function testStructToJsonConstrained2() returns json|error {
//    Person2 p = {   name:"Child",
//                    age:25
//                };
//    json<Person2> j = check json<Person2>.create(p);
//    return j;
//}
//
//function testStructToJsonConstrainedNegative() returns json {
//    Person2 p = {   name:"Child",
//                    age:25
//                };
//    json<Person3> j = ();
//    var result = json<Person3>.create(p);
//    if (result is json<Person3>) {
//        j = result;
//    } else if (result is error) {
//        panic result;
//    }
//    return j;
//}

function testAnyRecordToAnydataMap() returns (map | error) {
    Person4 p = {   name:"Waruna",
                    parent:{name:"Parent"},
                    address:{"city":"Colombo", "country":"SriLanka"}
    };
    map<anydata> m =  check map<anydata>.create(p);
    return m;
}

function testJsonToStruct () returns (Person | error) {
    json j = {name:"Child",
                 age:25,
                 parent:{
                            name:"Parent",
                            age:50,
                            parent:null,
                            address:null,
                            info:null,
                            marks:null,
                            a:null,
                            score:4.57,
                            alive:false,
                            children:null
                        },
                 address:{"city":"Colombo", "country":"SriLanka"},
                 info:{status:"single"},
                 marks:[56, 79],
                 a:"any value",
                 score:5.67,
                 alive:true
             };
    var p = Person.create(j);
    return p;
}

function testMapToStructWithMapValueForJsonField() returns Person|error {
    int[] marks = [87, 94, 72];
    map<string> addr = {"city":"Colombo", "country":"SriLanka"};
    map<string> info = {status:"single"};
    map m = {name:"Child",
                parent:(),
                age:25,
                address:addr,
                info:info,
                a:"any value",
                marks:marks,
                score:5.67,
                alive:true,
                children:()
            };
    Person p = check Person.create(m);
    return p;
}

function testMapWithMissingOptionalFieldsToStruct () returns Person|error {
    int[] marks = [87, 94, 72];
    map<string> addr = {"city":"Colombo", "country":"SriLanka"};
    map m = {name:"Child",
                parent:(),
                age:25,
                a:"any value",
                address:addr,
                marks:marks,
                score:5.67,
                alive:true
            };
    Person p = check Person.create(m);
    return p;
}

function testMapWithIncompatibleArrayToStruct () returns Person {
    float[] marks = [87.0, 94.0, 72.0];
    Person parent = {
                        name:"Parent",
                        age:50,
                        parent:null,
                        address:null,
                        info:null,
                        marks:null,
                        a:null,
                        score:5.67,
                        alive:false
                    };
    json info = {status:"single"};
    map<string> addr = {"city":"Colombo", "country":"SriLanka"};
    map m = {name:"Child",
                age:25,
                parent:parent,
                address:addr,
                info:info,
                marks:marks,
                a:"any value",
                score:5.67,
                alive:true
            };

    var p = Person.create(m);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

type Employee record {
    string name;
    int age;
    Person partner;
    json info;
    map<string> address;
    int[] marks;
    !...
};

function testMapWithIncompatibleStructToStruct () returns Employee {
    int[] marks = [87, 94, 72];
    Student s = {name:"Supun",
                    age:25
                };

    map<string> addr = {"city":"Colombo", "country":"SriLanka"};
    map<string> info = {status:"single"};
    map m = {name:"Child",
                age:25,
                partner:s,
                address:addr,
                info:info,
                marks:marks
            };
            
    var e = Employee.create(m);
    if (e is Employee) {
        return e;
    } else {
        panic e;
    }
}

function testJsonToStructWithMissingOptionalFields () returns Person {
    json j = {name:"Child",
                 parent:(),
                 age:25,
                 address:{"city":"Colombo", "country":"SriLanka"},
                 info:{status:"single"},
                 a:"any value",
                 marks:[87, 94, 72],
                 score:5.67,
                 alive:true
             };

    var p = Person.create(j);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

function testJsonToStructWithMissingRequiredFields () returns Person {
    json j = {name:"Child",
                 parent:(),
                 age:25,
                 address:{"city":"Colombo", "country":"SriLanka"},
                 info:{status:"single"},
                 a:"any value",
                 marks:[87, 94, 72],
                 score:5.67
             };

    var p = Person.create(j);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

function testIncompatibleJsonToStruct () returns Person {
    json j = {name:"Child",
                 age:"25",
                 address:{"city":"Colombo", "country":"SriLanka"},
                 info:{status:"single"},
                 marks:[87, 94, 72]
             };

    var p = Person.create(j);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

function testJsonWithIncompatibleMapToStruct () returns Person {
    json j = {name:"Child",
                 age:25,
                 parent:{
                            name:"Parent",
                            age:50,
                            parent:null,
                            address:"SriLanka",
                            info:null,
                            marks:null
                        },
                 address:{"city":"Colombo", "country":"SriLanka"},
                 info:{status:"single"},
                 marks:[87, 94, 72]
             };

    var p = Person.create(j);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

function testJsonWithIncompatibleTypeToStruct () returns Person {
    json j = {name:"Child",
                 age:25.8,
                 parent:{
                            name:"Parent",
                            age:50,
                            parent:null,
                            address:"SriLanka",
                            info:null,
                            marks:null
                        },
                 address:{"city":"Colombo", "country":"SriLanka"},
                 info:{status:"single"},
                 marks:[87, 94, 72]
             };

    var p = Person.create(j);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

function testJsonWithIncompatibleStructToStruct () returns Person {
    json j = {name:"Child",
                 age:25,
                 parent:{
                            name:"Parent",
                            age:50,
                            parent:"Parent",
                            address:{"city":"Colombo", "country":"SriLanka"},
                            info:null,
                            marks:null
                        },
                 address:{"city":"Colombo", "country":"SriLanka"},
                 info:{status:"single"},
                 marks:[87, 94, 72]
             };

    var p = Person.create(j);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

function testJsonArrayToStruct () returns Person {
    json j = [87, 94, 72];

    var p = Person.create(j);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

type Info record {
    map foo;
    !...
};

type Info2 record {
    byte[] infoBlob = [];
    !...
};

function testStructWithIncompatibleTypeMapToJson () returns (json) {
    byte[] b = [];
    map m = {bar:b};
    Info info = {foo:m};

    var j = json.create(info);
    if (j is json) {
        return j;
    } else {
        panic j;
    }
}

function testJsonIntToString () returns string|error {
    json j = 5;
    int value;
    value = check int.create(j);
    return  string.create(value);
}

function testFloatToInt() returns (int) {
    float f = 10.05344;
    int i = int.create(f);
    return i;
}

function testBooleanInJsonToInt () returns int|error {
    json j = true;
    int value = check int.create(j);
    return value;
}

function testIncompatibleJsonToInt () returns int|error {
    json j = "hello";
    int value;
    value = check int.create(j);
    return value;
}

function testIntInJsonToFloat () returns float|error {
    json j = 7;
    float value;
    value = check float.create(j);
    return value;
}

function testIncompatibleJsonToFloat () returns float|error {
    json j = "hello";
    float value;
    value = check float.create(j);
    return value;
}

function testIncompatibleJsonToBoolean () returns boolean|error {
    json j = "hello";
    boolean value;
    value = check boolean.create(j);
    return value;
}

type Address record {
    string city;
    string country;
    !...
};

type AnyArray record {
    anydata[] a;
    !...
};

function testJsonToAnyArray () returns AnyArray|error {
    json j = {a:[4, "Supun", 5.36, true, {lname:"Setunga"}, [4, 3, 7], null]};
    AnyArray value = check AnyArray.create(j);
    return value;
}

type IntArray record {
    int[] a;
    !...
};

function testJsonToIntArray () returns IntArray|error {
    json j = {a:[4, 3, 9]};
    IntArray value = check IntArray.create(j);
    return value;
}


type StringArray record {
    string[] a;
    !...
};

function testJsonToStringArray () returns StringArray|error {
    json j = {a:["a", "b", "c"]};
    StringArray a = check StringArray.create(j);
    return a;
}

function testJsonIntArrayToStringArray () returns StringArray|error {
    json j = {a:[4, 3, 9]};
    string[] s =  check string[].create(j["a"]);
    json j2 = {a:s};
    StringArray a = check StringArray.create(j2);
    return a;
}

type XmlArray record {
    xml[] a;
    !...
};

function testJsonToXmlArray () returns XmlArray {
    json j = {a:["a", "b", "c"]};
    var a = XmlArray.create(j);
    if (a is XmlArray) {
        return a;
    } else {
        panic a;
    }
}

function testNullJsonArrayToArray () returns StringArray {
    json j = {a:null};
    var a =  StringArray.create(j);
    if (a is StringArray) {
        return a;
    } else {
        panic a;
    }
}

function testNullJsonToArray () returns StringArray {
    json j = ();
    var s = StringArray.create(j);
    if (s is StringArray) {
        return s;
    } else {
        panic s;
    }
}

function testNonArrayJsonToArray () returns StringArray {
    json j = {a:"im not an array"};
    var a = StringArray.create(j);
    if (a is StringArray) {
        return a;
    } else {
        panic a;
    }
}


function testNullJsonToStruct () returns Person {
    json j = ();
    var p = Person.create(j);
    if (p is Person) {
        return p;
    } else {
        panic p;
    }
}

function testNullStructToJson () returns (json | error) {
    Person? p = ();
    var j = check json.create(p);
    return j;
}

function testIncompatibleJsonToStructWithErrors () returns (Person | error) {
    json j = {name:"Child",
                 age:25,
                 parent:{
                            name:"Parent",
                            age:50,
                            parent:"Parent",
                            address:{"city":"Colombo", "country":"SriLanka"},
                            info:null,
                            marks:null
                        },
                 address:{"city":"Colombo", "country":"SriLanka"},
                 info:{status:"single"},
                 marks:[87, 94, 72]
             };
             
    Person p  = check Person.create(j);
    return p;
}

type PersonA record {
    string name = "";
    int age = 0;
    !...
};

function JsonToStructWithErrors () returns (PersonA | error) {
    json j = {name:"supun"};

    PersonA pA = check PersonA.create(j);

    return pA;
}

type PhoneBook record {
    string[] names = [];
    !...
};

function testStructWithStringArrayToJSON () returns json|error {
    PhoneBook phonebook = {names:["John", "Doe"]};
    var phonebookJson = check json.create(phonebook);
    return phonebookJson;
}

type person record {
    string fname = "";
    string lname = "";
    int age = 0;
    !...
};

type movie record {
    string title = "";
    int year = 0;
    string released = "";
    string[] genre = [];
    person[] writers = [];
    person[] actors = [];
    !...
};

function testStructToMapWithRefTypeArray () returns (map, int)|error {
    movie theRevenant = {title:"The Revenant",
                            year:2015,
                            released:"08 Jan 2016",
                            genre:["Adventure", "Drama", "Thriller"],
                            writers:[{fname:"Michael", lname:"Punke", age:30}],
                            actors:[{fname:"Leonardo", lname:"DiCaprio", age:35},
                                    {fname:"Tom", lname:"Hardy", age:34}]};

    map<anydata> m = check map<anydata>.create(theRevenant);

    anydata a = m["writers"];
    var writers = person[].create(a);
    if(writers is person[]){
        return (m, writers[0].age);
    } else {
        return (m, 0);
    }
}

type StructWithDefaults record {
    string s = "string value";
    int a = 45;
    float f = 5.3;
    boolean b = true;
    json j = ();
    byte[] blb = [];
    !...
};

function testEmptyJSONtoStructWithDefaults () returns (StructWithDefaults | error) {
    json j = {};
    var testStruct = check StructWithDefaults.create(j);

    return testStruct;
}

type StructWithoutDefaults record {
    string s = "";
    int a = 0;
    float f = 0.0;
    boolean b = false;
    json j = {};
    byte[] blb = [];
    !...
};

function testEmptyJSONtoStructWithoutDefaults () returns (StructWithoutDefaults | error) {
    json j = {};
    var testStruct = check StructWithoutDefaults.create(j);

    return testStruct;
}


function testEmptyMaptoStructWithDefaults () returns StructWithDefaults|error {
    map m = {};
    var testStruct = check StructWithDefaults.create(m);

    return testStruct;
}


function testEmptyMaptoStructWithoutDefaults () returns StructWithoutDefaults|error {
    map m = {};
    var testStruct = check StructWithoutDefaults.create(m);

    return testStruct;
}

function testSameTypeConversion() returns (int) {
    float f = 10.05;
    var i =  int.create(f);
    i =  int.create(i);
    return i;
}

//function testNullStringToOtherTypes() (int, error,
//                                       float, error,
//                                       boolean, error,
//                                       json, error,
//                                       xml, error) {
//    string s;
//    var i, err1 = int.create(s);
//    var f, err2 = float.create(s);
//    var b, err3 = boolean.create(s);
//    var j, err4 = json.create(s);
//    var x, err5 = xml.create(s);
//    
//    return i, err1, f, err2, b, err3, j, err4, x, err5;
//}

function structWithComplexMapToJson() returns (json | error) {
    int a = 4;
    float b = 2.5;
    boolean c = true;
    string d = "apple";
    map<string> e = {"foo":"bar"};
    PersonA f = {};
    int [] g = [1, 8, 7];
    map m = {"a":a, "b":b, "c":c, "d":d, "e":e, "f":f, "g":g, "h":null};
    
    Info info = {foo : m};
    var js = check json.create(info);
    return js;
}

type ComplexArrayStruct record {
    int[] a;
    float[] b;
    boolean[] c;
    string[] d;
    map<anydata>[] e;
    PersonA[] f;
    json[] g;
    !...
};

function structWithComplexArraysToJson() returns (json | error) {
    json g = {"foo":"bar"};
    map<anydata> m1 = {};
    map<anydata> m2 = {};
    PersonA p1 = {name:""};
    PersonA p2 = {name:""};
    ComplexArrayStruct t = {a:[4, 6, 9], b:[4.6, 7.5], c:[true, true, false], d:["apple", "orange"], e:[m1, m2], f:[p1, p2], g:[g]};
    var js = check json.create(t);
    return js;
}

function testComplexMapToJson () returns json|error {
    map m = {name:"Supun",
                age:25,
                gpa:2.81,
                status:true
            };
    json j2 = check json.create(m);
    return j2;
}

function testStructWithIncompatibleTypeToJson () returns json {
    Info2 info = {
        infoBlob : [1, 2, 3, 4, 5]
    };
    var j = json.create(info);
    if (j is json) {
        return j;
    } else {
        panic j;
    }
}

function testJsonToMapUnconstrained() returns map|error {
    json jx = {};
    jx.x = 5;
    jx.y = 10;
    jx.z = 3.14;
    jx.o = {};
    jx.o.a = "A";
    jx.o.b = "B";
    jx.o.c = true;
    map<anydata> m = check map<anydata>.create(jx);
    return m;
}

function testJsonToMapConstrained1() returns map|error {
    json j = {};
    j.x = "A";
    j.y = "B";
  
    return check map<string>.create(j);
}

type T1 record {
    int x = 0;
    int y = 0;
};

function testJsonToMapConstrained2() returns map|error {
    json j1 = {};
    j1.x = 5;
    j1.y = 10;
    json j2 = {};
    j2.a = j1;
    map<T1> m;
    m = check map<T1>.create(j2);
    return m;
}

function testJsonToMapConstrainedFail() returns map {
    json j1 = {};
    j1.x = 5;
    j1.y = 10.5;
    json j2 = {};
    j2.a = j1;
    map<T1> m = {};
    var result = map<T1>.create(j2);
    if (result is map<T1>) {
        m = result;
    } else if (result is error){
        panic result;
    }
    return m;
}

type T2 record {
    int x = 0;
    int y = 0;
    int z = 0;
    !...
};

function testStructArrayConversion1() returns T1|error {
    T1[] a = [];
    T2[] b = [];
    b[0] = {};
    b[0].x = 5;
    b[0].y = 1;
    b[0].z = 2;
    a = T1[].create(b);
    return a[0];
}

function testStructArrayConversion2() returns T2|error {
    T1[] a = [];
    T2[] b = [];
    b[0] = {};
    b[0].x = 5;
    b[0].y = 1;
    b[0].z = 2;
    a = T1[].create(b);
    b = check T2[].create(a);
    return b[0];
}

public type T3 record {
  int x = 0;
  int y = 0;
};

public type O1 object {
  public int x = 0;
  public int y = 0;
};

public type O2 object {
  public int x = 0;
  public int y = 0;
  public int z = 0;
};

function testObjectRecordConversionFail() {
    O2 a = new;
    T3 b = {};
    var result = <O2> b;
    if (result is O2) {
        a = result;
    } else {
        panic result;
    }
}

function testTupleConversion1() returns (T1, T1)|error {
    T1 a = {};
    T2 b = {};
    (T1, T2) x = (a, b);
    (T1, T1) x2;
    anydata y = x;
    x2 = check (T1, T1).create(y);
    return x2;
}

function testTupleConversion2() returns (int, string)|error {
    (int, string) x = (10, "XX");
    anydata y = x;
    x = check (int, string).create(y);
    return x;
}

function testTupleConversionFail() {
    T1 a = {};
    T1 b = {};
    (T1, T1) x = (a, b);
    (T1, T2) x2;
    anydata y = x;
    var result = (T1, T2).create(y);
    if (result is (T1, T2)) {
        x2 = result;
    } else if (result is error) {
        panic result;
    }
}

function testArrayToJson1() returns json|error {
    int[] x = [];
    x[0] = 10;
    x[1] = 15;
    json j = check json.create(x);
    return j;
}

function testArrayToJson2() returns json|error {
    T1[] x = [];
    T1 a = {};
    T1 b = {};
    a.x = 10;
    b.x = 15;
    x[0] = a;
    x[1] = b;
    json j = check json.create(x);
    return j;
}

public type TX record {
  int x = 0;
  int y = 0;
  byte[] b = [];
};

function testArrayToJsonFail() returns json {
    TX[] x = [];
    TX a = {};
    TX b = {};
    a.x = 10;
    b.x = 15;
    x[0] = a;
    x[1] = b;
    var result = json.create(x);
    if (result is json) {
        return result;
    } else {
        panic result;
    }
}

function testJsonToArray1() returns T1[]|error {
    T1[] x = [];
    x[0] = {};
    x[0].x = 10;
    json j = check json.create(x);
    x = check T1[].create(j);
    return x;
}

function testJsonToArray2() returns int[]|error {
    json j = [];
    j[0] = 1;
    j[1] = 2;
    j[2] = 3;
    int[] x = check int[].create(j);
    return x;
}

function testJsonToArrayFail() {
    json j = {};
    j.x = 1;
    j.y = 1.5;
    var result = int[].create(j);
    if (result is int[]) {
        int[] x = result;
    } else if (result is error) {
        panic result;
    }
}

function testAnydataToFloat() returns float|error {
    anydata a = 5;
    return check float.create(a);
}

function testAnyToFloat() returns float|error {
    any a = 5;
    return check float.create(a);
}

type A record {
    float f = 0.0;
};

function testJsonIntToFloat() returns A|error {
    json j = {f : 3.0};
    return check A.create(j);
}
