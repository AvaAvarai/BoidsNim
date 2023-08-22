# Boids Simulation in Nim

Boids flocking simulation in 2D using Nim, OpenGL, and FreeGlut.

![Example flocking](BoidsGif.gif)

## Features

- Simulates the flocking behavior of boids using the classic three rules: alignment, cohesion, and separation.
- Boids avoid walls when they get close to the screen boundaries.
- Each boid is rendered in a unique shade of blue for easier distinction.

## Installation and Setup

1. Ensure you have Nim, OpenGL, and GLUT installed on your machine.
2. Clone the repository:

```bash
git clone <repository-url>
```

Navigate to the project directory:

```bash
cd <repository-directory>
```

Compile and run the project:

```bash
nim c -r boids.nim
```

## Usage

Watch the boids flock and interact in real-time.
Adjust parameters like the number of boids, maximum speed, view radius, etc., in the source code to see how it affects the simulation.

## Pre-compiled Releases for Windows Users

For Windows users, pre-compiled releases are available for download, including the executable .exe file and the required .dll files for OpenGL and FreeGLUT.

To get started:

1. Download the latest release zip from the Releases section.
2. Extract the zip file into a folder.
3. Run the .exe to start the simulation.

**Note**: Ensure that the .dll files are in the same directory as your .exe or in a directory listed in your system's PATH environment variable.

## License

This project is licensed under the GPL3 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Craig Reynolds for the original boids algorithm.
- OpenAI for guidance and suggestions in refining the simulation.
