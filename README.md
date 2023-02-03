# ComposableArchitectureForms

ComposableArchitectureForms is a library that introduces an opinionated pattern for handling Field Validation and focusState for SwiftUI forms, in projects built with The Composable Architecture

## Usage

Define a Reducer that conforms to the FormReducer Protocol. When using a FormReducer and the associated ViewModifiers, validation will be run in a specific way, to attempt to reduce the amount of error messages that appear on the screen, while forcing the user to enter valid data.

The first time validation is run is when the user "submits" a field, by moving the focus away from that field. This allows them to enter the entirety of the data they want to without getting an error message.

If they have an error message, when they return to that field, validation will be run on every keystroke, ensuring that any error disappears as soon as they get to a valid state.

The Field enum in the FormReducer also represents the ordering of fields in the View. This enables the library to set up the keyboard submit button to move the focus from one field to the next.

```swift
import ComposableArchitectureForms

struct Form: FormReducer {
   struct State: ValidatableState { ... }
   struct Action: ValidatableAction { ... }
   enum Field: ValidatableField { ... }
   static func validate(field: Field, state: State, errors: inout State.ValidationErrors) { ... }
   var formBody: some ReducerProtocol<State, Action> { ... }
}
```



## Example:
### Example Reducer:
```swift 
struct ClientForm: FormReducer {
    struct State: ValidatableState {
        // This struct contains any error messages for the fields
        struct ValidationErrors: ValidationErrorCollection {
            var ageError: String?
            var emailError: String?
        }
        
        // Form State required by ValidatableState protocol
        var errors: ValidationErrors = .init()
        var isValid: Bool = false
        @BindingState var focusedField: Field?
        
        // Form Data
        @BindingState var name: String = ""
        @BindingState var email: String = ""
        @BindingState var age: Int = 0
    }
    
    enum Action: ValidatableAction {
        // These actions are required by the ValidatableAction protocol
        case binding(_ action: BindingAction<State>)
        case validate(_ field: Field)
        case focus(_ action: FocusAction<Field>)
        
        // Add additional actions as needed
        case didTapSaveButton
    }
    
    // Define the fields that exist in the form.
    // The ordering of cases determines what field comes into focus when the "next" button is tapped on the keyboard
    // The last enum case will automatically get a "done" submit button instead of "next"
    enum Field: ValidatableField {
        case name
        case email
        case age
        
        // This associates the Field enum case with the State value it represents, and it's (optional) error message
        var fieldDataLocation: FieldDataLocation<State> {
            switch self {
            case .name: return (value: \.name, error: nil)
            case .email: return (value: \.email, error: \.emailError)
            case .age: return (value: \.age, error: \.ageError)
            }
        }
    }
    
    // formBody is the equivalent of the body property in a standard reducer, but includes the validation, focus and binding reducers required to drive the form
    var formBody: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .binding, .validate, .focus:
                return .none

            case .didTapSaveButton:
                validateAll(state: &state)
                
                if state.isValid {
                    // Save form data
                }
                
                return .none
            }
        }
    }
    
    // Defines how validation is run.
    // For any field and state, run the validation and assign an error message to the ValidationErrorCollection
    static func validate(field: Field, state: State, errors: inout State.ValidationErrors) {
        switch field {
        case .name:
            break
        case .email:
            if state.email.isEmpty {
                errors.emailError = "Please enter an email"
            } else if !state.email.localizedStandardContains("@") {
                errors.emailError = "Please enter a valid email"
            } else {
                errors.emailError = nil // Ensure we set the error to nil if the field is valid
            }
        case .age:
            errors.ageError = state.age < 18 ? "You must be 18 to create an account" : nil
        }
    }
}
```
### Example View
```swift
struct ClientFormView: View {
    
    var store: StoreOf<ClientForm>
    
    var body: some View {
        // Create your form UI however you want
        WithViewStore(store) { viewStore in
            Form {
                // Attach the .validation viewModifier to a textField to associate an input with its FormReducer.Field
                TextField("Name", text: viewStore.binding(\.$name))
                    .validation(store, field: .name)
                
                TextField("Email", text: viewStore.binding(\.$email))
                    .validation(store, field: .email)
                
                Stepper("Age: \(viewStore.age)", value: viewStore.binding(\.$age))
                    .validation(store, field: .age)
            }
            .navigationTitle("Client Form")
            .toolbar {
                ToolbarItem {
                    Button("Save") {
                        viewStore.send(.didTapSaveButton)
                    }
                    .foregroundColor(viewStore.isValid ? Color.accentColor : .gray) // You may disable the button with this property, but changing the color allows the user to still tap it and see all of their failed validation
                }
            }
        }
    }
}
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
