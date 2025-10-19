# Brain-Bloom
Authors: Brian, Sydney, Tian, Aaron

## Mobile App (Figma Demo):
• Prototype: 
https://www.figma.com/proto/ynm5qr0RCP3NLRiIwWDaO8/DubsHack-2025?page-id=0%3A1&node-id=2-83&p=f&viewport=798%2C430%2C1.29&t=5bSOGzpabz1hhTjw-1&scaling=min-zoom&content-scaling=fixed&starting-point-node-id=2%3A83
• WireFrame Layout:
https://www.figma.com/design/ynm5qr0RCP3NLRiIwWDaO8/DubsHack-2025?node-id=0-1&t=G6PbJpgluB0yKi14-1
• Brainstorm/Sketches:
https://www.figma.com/board/njmMfpYnDrf7eSzFSNX0ry/DubHacks2025?node-id=0-1&t=qRUoyMV7rDaG79QB-1

## Inspiration
The inspiration for this project came from the agency that allowances gave us as kids, allowing us to grow in our work discipline while building skills in saving up money for the things we cared about.
## What it does
Brain-bloom serves as a digital allowance system that encourages young children to grow their math skills to gain their allowance for the week. Parents can purchase in-app tokens that are awarded to kids upon the completion of a chosen number of AI generated math problems per day. The difficulty and amount of questions can be selected by parents, along with the amount of tokens awarded.
## How we built it
We built the application using Flutter as the frontend and Dart as the backend. We implemented Stripe's payment intent API to accept card payment for purchasing tokens, along with Gemini's AI API to generate math questions to solve. Finally, we used Figma to wireframe and prototype the app.
## Challenges we ran into
We ran into some issues with Stripe's API requiring access to certain mobile OS functionalities when many of us used a web emulator to develop. To overcome this challenge, we developed a parallel workflow for Stripe JS that allowed us to use both mobile and web versions of the application. 
## Accomplishments that we're proud of
We are most proud of the quick turn-around time for the project given its complexity. We are also proud of the work we did with unfamiliar technologies and how they helped us develop our flexibility as software engineers.
## What we learned
This was the first hackathon for half of our members, and so we learned about quick ideation and implementation of innovative ideas. Additionally, many of us did not have experience with Flutter before, and so this project served as a first introduction to the framework. Finally, this was our first experience implementing payment into an application before and so we learned about the basics of accepting payment from a user.
## What's next for Math Kids
While we were unable to implement it in our project today, we look to allow kids to utilize their tokens to  save up towards their goals and have funds transferred to a prepaid card for purchases.
