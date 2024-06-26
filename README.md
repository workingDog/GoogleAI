# SwiftUI Google Gemini AI demo App

A chat-like SwiftUI Google Gemini REST API demo App, includes text and image input.

Using, the **Google AI SDK for Swift** Client Library in Swift [Google AI SDK for Swift](https://github.com/google/generative-ai-swift).


<p float="left">
  <img src="Images/s2.png" width="333"  height="444" />
    <img src="Images/s1.png" width="333"  height="444" />
</p>


### Usage

-   **Pick** the conversation mode first, `Chat`, `Image` or `Camera`, 
then type a question **before** you tap on the main button.

    - `Chat` for chat like interaction,
    - `Image` for selecting one or more images from the Photos library,
    - `Camera` to take one picture using the camera.
    
-   **Tap** on a question or answer text, to **copy** the text to the `Pasteboard` and enable you to paste it elsewhere or `share` it. Similarly, tap on the picture to copy just the image.
  
-   **Swipe left** on a question/answer, to deleted it.
  
-   **Tap** on the `trash can`, to delete **all** questions and answers. 

-   **Tap** on the `share`, to share the previously tapped text or picture. 


#### Settings

Press the **gear shape** icon to:

-   enter the **required** api key,
-   select the model parameters,
-   select the UI colors,
-   select the UI language

Note, the [Google AI key](https://ai.google.dev/) is stored securely on the device keychain.

  
### References and dependencies

-    [Google AI SDK for Swift](https://github.com/google/generative-ai-swift)
-    [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui)

### Requirement

**Requires** a valid API key, see:

-    [Google AI for developers](https://ai.google.dev/)
-    [REST API](https://ai.google.dev/tutorials/rest_quickstart)

Copy and paste the key into the **Settings** ("gear shape") and save it in the `Enter key` area.

### License

The MIT License (MIT)
