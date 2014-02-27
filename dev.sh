#!/bin/bash
export DATABASE_URL="sqlite::memory:"

rerun 'ruby app.rb'
