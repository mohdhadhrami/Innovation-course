<?php
header('Content-Type: application/javascript; charset=utf-8');
header('Cache-Control: no-store');
$key = $_SERVER['OPENAI_API_KEY'] ?? getenv('OPENAI_API_KEY') ?: '';
$pwd = $_SERVER['TRAINER_PASSWORD'] ?? getenv('TRAINER_PASSWORD') ?: '';
echo "window.ENV = " . json_encode([
  'OPENAI_API_KEY'   => $key,
  'TRAINER_PASSWORD' => $pwd,
]) . ";";
