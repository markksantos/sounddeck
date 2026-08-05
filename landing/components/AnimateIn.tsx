"use client";

import { motion, useReducedMotion } from "framer-motion";
import { ReactNode } from "react";

interface AnimateInProps {
  children: ReactNode;
  className?: string;
  delay?: number;
}

export default function AnimateIn({
  children,
  className,
  delay = 0,
}: AnimateInProps) {
  const shouldReduceMotion = useReducedMotion();

  return (
    <motion.div
      initial={false}
      whileInView={shouldReduceMotion ? undefined : { opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, delay, ease: [0.25, 0.1, 0.25, 1] }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
