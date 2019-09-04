func xxx(boolInput: Bool, intInput: Int, strInput: String)
    -> (_ boolOutput: Bool)
    -> (_ intOutput: Int)
    -> String {
        return { bool in
            return { int in
                return "bool is \(bool), int is \(int)\nboolInput is \(boolInput), intInput is \(intInput), strInput is \(strInput)"
            }
        }
}
let xxxOutput0 = xxx(boolInput: true, intInput: 10, strInput: "Hello")
print("xxxOutput0: \(String(describing: xxxOutput0))")
let xxxOutput1 = xxxOutput0(false)
print("xxxOutput1: \(String(describing: xxxOutput1))")
let xxxOutput2 = xxxOutput1(5)
print("xxxOutput2: \(xxxOutput2)")
