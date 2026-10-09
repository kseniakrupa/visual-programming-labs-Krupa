@echo off
chcp 65001 >nul
title Демонстрация CRUD - лабораторная работа №2
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0demo-crud.ps1"
