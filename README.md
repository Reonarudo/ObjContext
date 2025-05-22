# ObjContext

ObjContext is an Objective-C framework designed to facilitate Context-Oriented Programming. This allows applications to dynamically adapt their behavior based on the current execution environment or situation.

## Key Concepts

### Context-Oriented Programming (COP)
Context-Oriented Programming is a programming paradigm that enables software to adapt its behavior to the current context of execution. It allows developers to define and manage context-dependent variations in program behavior in a modular and structured way.

### Contexts
In ObjContext, Contexts represent specific situations or environmental conditions that are relevant to the application's behavior. These can include, but are not limited to:
*   User's current location (e.g., home, work, outdoors)
*   Device state (e.g., battery level, network connectivity, screen orientation)
*   Time of day (e.g., morning, afternoon, night)
*   User activity (e.g., walking, driving, idle)

The framework allows for the definition and monitoring of these contexts.

### Adaptations
Adaptations define how the application's behavior should change when one or more specific contexts become active. They essentially map contexts to behavioral changes. When a context is activated, the corresponding adaptations are triggered, modifying the application's functionality accordingly. This allows for a clear separation of concerns, where the core application logic remains independent of context-specific adjustments.

### Behaviors
Behaviors are the parts of an application that are designed to be adaptable. These are typically specific methods or functionalities within the application whose execution can vary depending on the active context. By identifying and isolating these behaviors, developers can use ObjContext to dynamically swap or modify them at runtime based on the active adaptations.

## Main Classes

The ObjContext framework is composed of several key classes that work together to enable context-aware behavior:

*   **`ObjectiveContextualizer`**: This is the main entry point for interacting with the ObjContext framework. It initializes and configures the necessary components, such as the `ContextManager` and `AdaptationManager`. Developers use this class to set up the context-oriented aspects of their application.

*   **`ContextManager`**: Responsible for managing the definitions and lifecycle of all contexts within the application. It allows for the registration, activation, and deactivation of contexts. It keeps track of the current state of all defined contexts.

*   **`ContextMonitor`**: This class is responsible for observing and reporting changes in the application's environment that are relevant to specific contexts. It detects changes (e.g., location update, time change) and informs the `ContextManager` about these changes, which can lead to context activation or deactivation.

*   **`Adaptation`**: An `Adaptation` class (or instances of it) defines the rules for how an application's behavior should be modified when certain contexts are active. It specifies which `Behavior` (methods or functionalities) should be altered and how, in response to a particular context or combination of contexts.

*   **`Behavior`**: In ObjContext, `Behavior` often refers to a protocol or a set of conventions that mark parts of the application as adaptable. Objects conforming to this protocol or these conventions can have their methods dynamically replaced or augmented by the framework based on active adaptations. It represents the adaptable units of functionality.

*   **`Cntxt`**: Represents a specific context within the framework (e.g., "UserAtHome", "LowBattery"). Instances of `Cntxt` (or subclasses) encapsulate the conditions and logic for determining if that particular context is currently active. These objects are managed by the `ContextManager`.

## Typical Workflow

Developing a context-aware application using the ObjContext framework generally follows these steps:

1.  **Define Contexts**:
    *   The developer first identifies the various contexts that are relevant to the application's behavior.
    *   These contexts are then formally defined. ObjContext often allows context definitions via configuration files (e.g., a `.plist` file specifying context names and associated parameters) or programmatically by creating instances of `Cntxt` or its subclasses. Each context will have a unique identifier.

2.  **Implement Context Sensing Logic**:
    *   For each defined context, the developer needs to implement the logic that determines if the context is currently active. This is typically done by creating subclasses of `ContextMonitor` or by providing sensing modules that integrate with device sensors, system services, or other sources of contextual information (e.g., GPS for location, system APIs for network status).
    *   These monitors observe the environment and report relevant changes to the `ContextManager`. The `ContextManager` then updates the status of the affected `Cntxt` objects.

3.  **Define Adaptations**:
    *   Once contexts are defined and can be sensed, the developer defines `Adaptation`s.
    *   An adaptation specifies which application `Behavior`s (e.g., methods of certain classes) should change when a particular context (or combination of contexts) becomes active.
    *   This involves mapping one or more contexts to specific behavioral variations. For example, "If 'UserAtHome' context is active, then use the 'WiFiDataService' behavior instead of 'CellularDataService'." This might also be configurable through files or programmatically.

4.  **Framework-Managed Dynamic Behavior**:
    *   The `ObjectiveContextualizer` is initialized at application startup, setting up the `ContextManager` with the defined contexts and monitors, and the `AdaptationManager` with the defined adaptations.
    *   At runtime, as `ContextMonitor`s detect changes in the environment, they notify the `ContextManager`.
    *   The `ContextManager` updates the state of the relevant `Cntxt` objects (activating or deactivating them).
    *   The `AdaptationManager` observes these context changes. When a context linked to an adaptation becomes active, the `AdaptationManager` enforces the specified behavioral changes. This typically involves dynamically modifying the application's code at runtime, such as by swapping method implementations or adjusting object properties, to reflect the desired adaptation. The core application logic can thus remain unaware of these dynamic adjustments, focusing on its primary tasks.

## Use Case Examples

The ObjContext framework can be leveraged to build a wide variety of adaptive applications. Here are some illustrative examples:

*   **Location-Aware UI and Functionality**:
    *   **Contexts**: `UserAtHome`, `UserAtWork`, `UserOutdoors`.
    *   **Adaptations**:
        *   When `UserAtHome` is active, the application might display a personalized home screen widget or enable features specific to home automation.
        *   When `UserAtWork` is active, the app could switch to a professional theme, prioritize work-related notifications, or automatically log into work-related services.
        *   When `UserOutdoors` is active, the UI might switch to a high-contrast theme for better visibility, or a map application might pre-load offline maps if network is also spotty.

*   **Device Status Driven Behavior**:
    *   **Contexts**: `LowBattery`, `NoNetworkConnection`, `OnWiFi`, `ScreenInLandscape`.
    *   **Adaptations**:
        *   If `LowBattery` is active, the application could automatically disable background data synchronization, reduce screen brightness (if controlling it), or switch to a less power-intensive mode.
        *   If `NoNetworkConnection` is active, features requiring internet access could be gracefully disabled, and the app might offer offline alternatives or queue outgoing data.
        *   When `OnWiFi` is active, the app could automatically download large updates or sync high-resolution media.
        *   When `ScreenInLandscape`, a video player might automatically switch to full-screen.

*   **Time-Based Adjustments**:
    *   **Contexts**: `Morning`, `Afternoon`, `Evening`, `NightMode`.
    *   **Adaptations**:
        *   A news application could display a "Good Morning" greeting and a summary of morning headlines when `Morning` is active.
        *   During `Evening`, a smart home application might suggest an "Evening" scene that dims lights and adjusts the thermostat.
        *   If a user-defined `NightMode` context is active (or inferred from time), the application's UI can switch to a dark theme to reduce eye strain.

*   **Activity-Responsive Features**:
    *   **Contexts**: `UserDriving`, `UserRunning`, `UserCycling`, `UserIdle`.
    *   **Adaptations**:
        *   When `UserDriving` is active, a music app might switch to a simplified interface with larger buttons, and a messaging app could automatically read messages aloud and enable voice replies.
        *   If `UserRunning` is active, a fitness app could automatically start tracking the run, display relevant metrics, and play a workout playlist.
        *   When `UserIdle` for a prolonged period, the application might dim its screen or enter a power-saving state.

These examples demonstrate how ObjContext can enable applications to provide a more intelligent, personalized, and efficient user experience by reacting dynamically to changes in their execution environment and user situation.

## Configuration

The ObjContext framework offers flexibility in how contexts and adaptations are defined:

*   **Context Model Configuration**: The framework utilizes `.plist` (Property List) files for configuring parts of the context model. For instance, the `c2amm.plist` file found within the framework likely defines mappings or settings related to context activation or adaptation management. This allows developers to define and modify certain context parameters without recompiling the application.

*   **Adaptation Definitions**: `Adaptation` objects, which specify how application behavior should change in response to contexts, are designed to be readable from JSON format. This means that developers can define complex adaptation rules, including which behaviors to modify and under what contextual conditions, in separate JSON files. This approach promotes a clean separation between the application's core logic and its adaptive strategies, making it easier to manage and update adaptations.
