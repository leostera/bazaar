window.Bazaar = {}
Bazaar.users = new Set()
Bazaar.userCbs = []
Bazaar.addUser = (user) => {
  Bazaar.users.add(user);
  Bazaar.userCbs.forEach(fn => fn(user));
}
Bazaar.onNewUser = (fn) => { Bazaar.userCbs.push(fn) }

let Engine = Matter.Engine,
    Render = Matter.Render,
    Runner = Matter.Runner,
    MouseConstraint = Matter.MouseConstraint,
    Mouse = Matter.Mouse,
    Composite = Matter.Composite,
    Bodies = Matter.Bodies;


window.addEventListener("load", () => {
let canvas = document.getElementById("playground")
let canvasBounds = canvas.getBoundingClientRect()
let width = canvasBounds.width
let height = canvasBounds.height

// create engine
let engine = Engine.create();
engine.gravity.scale = 0.002;
let world = engine.world;
console.log(world);

// create renderer
let render = Render.create({
  canvas,
  context: canvas.getContext("2d"),
  engine: engine,
  options: {
    height,
    width,
    wireframes: false,
    background: 'transparent',
  }
});

Render.run(render);

// create runner
let runner = Runner.create();
Runner.run(runner, engine);

const shape = (x, y, size, texture) => {
  return Bodies.rectangle(x, y, size, size, { 
    frictionAir: 0.01,
    render: {
      strokeStyle: '#ffffff',
      sprite: {
        texture,
        yScale: 0.2,
        xScale: 0.2,
      }
    }
  })
}


let boxSize = 50;
let wallSize = 50; 
Bazaar.onNewUser((user) => {
  Composite.add(world, [
    shape(400, 100, boxSize, user.profile_image_url)
  ])
})

const x = (factor) => Math.round(factor * width)
const y = (factor) => Math.round(factor * height)

let me = "https://static-cdn.jtvnw.net/jtv_user_pictures/4194ec93-3143-4ee1-8786-84d0ba0773eb-profile_image-300x300.png";
// add bodies
let wallOpts = { isStatic: true, render: { fillStyle: "transparent" } };
Composite.add(world, [
    // falling blocks
    shape(200, 100, boxSize, me),

    // walls
  Bodies.rectangle(0, 0, width*2, wallSize, wallOpts),
    Bodies.rectangle(0, height-(wallSize/2), width*2, wallSize, wallOpts),
    Bodies.rectangle(0, 0, wallSize, height*2, wallOpts),
    Bodies.rectangle(width, 0, wallSize, height*2, wallOpts),
]);

// add mouse control
let mouse = Mouse.create(render.canvas),
    mouseConstraint = MouseConstraint.create(engine, {
        mouse: mouse,
        constraint: {
            stiffness: 0.2,
            render: {
                visible: false
            }
        }
    });

Composite.add(world, mouseConstraint);

// keep the mouse in sync with rendering
render.mouse = mouse;

// fit the render viewport to the scene
Render.lookAt(render, {
    min: { x: 0, y: 0 },
    max: { x: width, y: height }
});

// context for MatterTools.Demo
Bazaar.engine = {
    engine: engine,
    runner: runner,
    render: render,
    canvas: render.canvas,
    stop: function() {
        Matter.Render.stop(render);
        Matter.Runner.stop(runner);
    }
};

});

async function getCurrentUser(auth) { 
  let token = auth.helixToken;
  let userId = window.Twitch.ext.viewer.id;
  return fetch(`https://api.twitch.tv/helix/users?id=${userId}`, {
  headers: {
  "Client-Id": "mjsy3vbf86v9cfbpygrru2et19sdbk",
  "Authorization": `Extension ${token}`,
  }})
  .then(res => res.json())
  .then(res => res.data[0])
}

window.Twitch.ext.onAuthorized(async (auth) => {
  let currentUser = await getCurrentUser(auth);
  console.log("current user: ", currentUser);

  const url = "wss://bazaar.fly.dev/playground"

  let socket = new WebSocket(url);

  socket.onopen = (event) => {
    console.log("connected: ", event);
    let msg = { name: currentUser.login, avatar_url: curretnUser.profile_image_url };
    console.log("sending: ", msg);
    socket.send(JSON.stringify(msg));
  };

  socket.onmessage = (event) => {
    let msg = JSON.parse(event.data);
    console.log("received: ", msg);
    let user = { login: msg.user, profile_image_url: msg.avatar_url };
    Bazaar.addUser(user)
  };

})

