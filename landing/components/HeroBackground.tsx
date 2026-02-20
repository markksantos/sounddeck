"use client";

import { Canvas, useFrame } from "@react-three/fiber";
import { useMemo, useRef } from "react";
import * as THREE from "three";

function Particles() {
  const ref = useRef<THREE.Points>(null);
  const count = 120;

  const positions = useMemo(() => {
    const pos = new Float32Array(count * 3);
    for (let i = 0; i < count; i++) {
      pos[i * 3] = (Math.random() - 0.5) * 20;
      pos[i * 3 + 1] = (Math.random() - 0.5) * 12;
      pos[i * 3 + 2] = (Math.random() - 0.5) * 8;
    }
    return pos;
  }, []);

  useFrame((_, delta) => {
    if (ref.current) {
      ref.current.rotation.y += delta * 0.02;
      ref.current.rotation.x += delta * 0.01;
    }
  });

  return (
    <points ref={ref}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          args={[positions, 3]}
        />
      </bufferGeometry>
      <pointsMaterial
        size={0.04}
        color="#3B82F6"
        transparent
        opacity={0.35}
        sizeAttenuation
      />
    </points>
  );
}

export default function HeroBackground() {
  return (
    <div className="absolute inset-0 -z-10">
      <Canvas
        camera={{ position: [0, 0, 6], fov: 60 }}
        style={{ background: "transparent" }}
        gl={{ alpha: true, antialias: true }}
      >
        <Particles />
      </Canvas>
    </div>
  );
}
